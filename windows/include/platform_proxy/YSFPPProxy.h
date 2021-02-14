#pragma once

#include <string>

class YSFPPProxy {
private:
	std::wstring host;
	std::wstring port;
	std::wstring user;
	std::wstring password;
	std::wstring type;
public:
	YSFPPProxy(std::wstring host, std::wstring port, std::wstring user, std::wstring password, std::wstring type);
	std::wstring json();
};