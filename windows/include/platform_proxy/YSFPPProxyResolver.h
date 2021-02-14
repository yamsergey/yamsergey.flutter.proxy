#pragma once

#pragma comment(lib, "winhttp.lib")

#include <iostream>
#include <Windows.h>
#include <winhttp.h>

// TODO: Reference additional headers your program requires here.
#include <vector>
#include "YSFPPProxy.h"

class YSFPPProxyResolver {

public:
	std::vector<YSFPPProxy> resolveProxies(std::wstring url);

	std::string resolveProxiesAsJson(std::wstring url);
};