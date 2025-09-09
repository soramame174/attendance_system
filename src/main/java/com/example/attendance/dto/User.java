package com.example.attendance.dto;

public class User {
	private String username;
	private String password;
	private String role;
	private boolean enabled;
	private String companyCode;
	private String registrationCode;

	public User(String username, String password, String role, String companyCode) {
		this(username, password, role, true, companyCode, null);
	}
	
	public User(String username, String password, String role, boolean enabled, String companyCode) {
		this(username, password, role, enabled, companyCode, null);
	}

	public User(String username, String password, String role, boolean enabled, String companyCode, String registrationCode) {
		this.username = username;
		this.password = password;
		this.role = role;
		this.enabled = enabled;
		this.companyCode = companyCode;
		this.registrationCode = registrationCode;
	}

	public String getUsername() {
		return username;
	}
	
	public String getPassword() {
		return password;
	}
	
	public String getRole() {
		return role;
	}

	public boolean isEnabled() {
		return enabled;
	}
		
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public String getCompanyCode() {
		return companyCode;
	}
	
	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public String getRegistrationCode() {
		return registrationCode;
	}

	public void setRegistrationCode(String registrationCode) {
		this.registrationCode = registrationCode;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public void setPassword(String password) {
		this.password = password;
	}
}