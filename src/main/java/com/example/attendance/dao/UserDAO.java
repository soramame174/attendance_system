package com.example.attendance.dao;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import com.example.attendance.dto.ProvisionalUser;
import com.example.attendance.dto.User;

public class UserDAO {
	// Map<会社コード, Map<ユーザーID, User>>
	private static final Map<String, Map<String, User>> companyUsers = new ConcurrentHashMap<>();
	// Map<登録コード, User>
	private static final Map<String, ProvisionalUser> registrationCodes = new ConcurrentHashMap<>();
	
	static {
		// サンプルユーザーデータ (ログインテスト用) を再追加
		String sampleCompanyCode = "company1";
		companyUsers.computeIfAbsent(sampleCompanyCode, k -> new ConcurrentHashMap<>()).put("admin1", new User("admin1", hashPassword("adminpass"), "admin", true, sampleCompanyCode, null));
		companyUsers.get(sampleCompanyCode).put("employee1", new User("employee1", hashPassword("password"), "employee", true, sampleCompanyCode, null));

		String anotherCompanyCode = "company2";
		companyUsers.computeIfAbsent(anotherCompanyCode, k -> new ConcurrentHashMap<>()).put("admin2", new User("admin2", hashPassword("password"), "admin", true, anotherCompanyCode, null));
	}
	
	public User findByUsernameAndCompanyCode(String companyCode, String username) {
		if (companyUsers.containsKey(companyCode)) {
			return companyUsers.get(companyCode).get(username);
		}
		return null;
	}
	
	public User findByRegistrationCode(String registrationCode) {
	    ProvisionalUser provisionalUser = registrationCodes.get(registrationCode);
	    if (provisionalUser != null) {
	        return provisionalUser.getUser();
	    }
	    return null;
	}
	
	public boolean companyExists(String companyCode) {
		return companyUsers.containsKey(companyCode);
	}

	public boolean verifyPassword(String companyCode, String username, String password) {
		User user = findByUsernameAndCompanyCode(companyCode, username);
		return user != null && user.isEnabled() && user.getPassword().equals(hashPassword(password));
	}
	
	public Collection<User> getAllUsers(String companyCode) {
		if (companyUsers.containsKey(companyCode)) {
			return companyUsers.get(companyCode).values();
		}
		return new HashMap<String, User>().values();
	}
	
	public void addUser(User user) {
		companyUsers.computeIfAbsent(user.getCompanyCode(), k -> new ConcurrentHashMap<>()).put(user.getUsername(), user);
	}
	
	public void updateUser(User user) {
		companyUsers.get(user.getCompanyCode()).put(user.getUsername(), user);
	}
	
	public void deleteUser(String companyCode, String username) {
		if (companyUsers.containsKey(companyCode)) {
			companyUsers.get(companyCode).remove(username);
		}
	}
	
	public void resetPassword(String companyCode, String username, String newPassword) {
		User user = findByUsernameAndCompanyCode(companyCode, username);
		if (user != null) {
			updateUser(new User(user.getUsername(), hashPassword(newPassword), user.getRole(), user.isEnabled(), user.getCompanyCode(), user.getRegistrationCode()));
		}
	}
	
	public void toggleUserEnabled(String companyCode, String username, boolean enabled) {
		User user = findByUsernameAndCompanyCode(companyCode, username);
		if (user != null) {
			updateUser(new User(user.getUsername(), user.getPassword(), user.getRole(), enabled, user.getCompanyCode(), user.getRegistrationCode()));
		}
	}

	public ProvisionalUser createProvisionalUser(String companyCode) {
	    // 既存のコードをクリア
	    registrationCodes.clear();
	    // UUID.randomUUID()を使ってユニークなコードを生成
	    String registrationCode = UUID.randomUUID().toString();
	    // 有効期限を現在から10分後に設定
	    LocalDateTime expireAt = LocalDateTime.now().plusMinutes(10);
	    User provisionalUser = new User(null, null, "employee", false, companyCode, registrationCode);
	    ProvisionalUser pvUser = new ProvisionalUser(provisionalUser, expireAt);
	    
	    // ProvisionalUser型のオブジェクトをマップに格納する
	    registrationCodes.put(registrationCode, pvUser);
	    
	    System.out.println("DEBUG: Provisional user created with code: " + registrationCode);
	    return pvUser;
	}
	
	public void deleteProvisionalUser(String registrationCode) {
		registrationCodes.remove(registrationCode);
		System.out.println("DEBUG: Provisional user with code: " + registrationCode + " has been deleted.");
	}
	
	public boolean createFirstAdmin(String companyCode, String username, String password) {
		if (companyExists(companyCode)) {
			return false;
		}
		User adminUser = new User(username, hashPassword(password), "admin", true, companyCode, null);
		addUser(adminUser);
		return true;
	}

	public boolean finalizeProvisionalUser(String registrationCode, String username, String password) {
	    // MapからProvisionalUserオブジェクトを取得する
	    ProvisionalUser provisionalUser = registrationCodes.get(registrationCode);

	    // 有効期限が切れていないか、ユーザー名が重複していないかチェック
	    if (provisionalUser != null
	            && provisionalUser.getRemainingSeconds() > 0 // 有効期限が切れていないかチェック
	            && !companyUsers.getOrDefault(provisionalUser.getUser().getCompanyCode(), new ConcurrentHashMap<>()).containsKey(username)) {
	        
	        // ProvisionalUserオブジェクトからUserオブジェクトを取得して更新
	        User userToFinalize = provisionalUser.getUser();
	        userToFinalize.setUsername(username);
	        userToFinalize.setPassword(hashPassword(password));
	        userToFinalize.setEnabled(true);
	        
	        // 最終的なUserオブジェクトをマップに追加
	        addUser(userToFinalize);
	        
	        // 登録コードをマップから削除
	        registrationCodes.remove(registrationCode);
	        return true;
	    }
	    return false;
	}

	public static String hashPassword(String password) {
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-256");
			byte[] hashedBytes = md.digest(password.getBytes());
			StringBuilder sb = new StringBuilder();
			for (byte b : hashedBytes) {
				sb.append(String.format("%02x", b));
			}
			return sb.toString();
		} catch (NoSuchAlgorithmException e) {
			throw new RuntimeException(e);
		}
	}
}