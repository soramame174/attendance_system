package com.example.attendance.dao;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import com.example.attendance.dto.User;

public class UserDAO {
	// Map<会社コード, Map<ユーザーID, User>>
	private static final Map<String, Map<String, User>> companyUsers = new ConcurrentHashMap<>();
	// Map<登録コード, User>
	private static final Map<String, User> registrationCodes = new ConcurrentHashMap<>();
	
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
		return registrationCodes.get(registrationCode);
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

	public String createProvisionalUser(String companyCode) {
		String registrationCode = UUID.randomUUID().toString().substring(0, 8);
		User provisionalUser = new User(null, null, "employee", false, companyCode, registrationCode);
		registrationCodes.put(registrationCode, provisionalUser);
		System.out.println("DEBUG: Provisional user created with code: " + registrationCode);
		return registrationCode;
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
		User provisionalUser = registrationCodes.get(registrationCode);
		if (provisionalUser != null && !companyUsers.getOrDefault(provisionalUser.getCompanyCode(), new ConcurrentHashMap<>()).containsKey(username)) {
			provisionalUser.setUsername(username);
			provisionalUser.setPassword(hashPassword(password));
			provisionalUser.setEnabled(true);
			addUser(provisionalUser);
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