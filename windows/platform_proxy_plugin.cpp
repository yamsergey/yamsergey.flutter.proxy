// https://github.com/google/flutter-desktop-embedding/blob/master/plugins/file_selector/file_selector_windows/windows/file_selector_plugin.cpp
// This must be included before many other Windows headers.
#include <windows.h>

#include "include/platform_proxy/platform_proxy_plugin.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <cassert>
#include <regex>

namespace
{

  // Converts the given UTF-16 string to UTF-8.
  std::string Utf8FromUtf16(const std::wstring &utf16_string)
  {
    if (utf16_string.empty())
    {
      return std::string();
    }
    int target_length = ::WideCharToMultiByte(
        CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string.data(),
        static_cast<int>(utf16_string.length()), nullptr, 0, nullptr, nullptr);
    if (target_length == 0)
    {
      return std::string();
    }
    std::string utf8_string;
    utf8_string.resize(target_length);
    int converted_length = ::WideCharToMultiByte(
        CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string.data(),
        static_cast<int>(utf16_string.length()), utf8_string.data(),
        target_length, nullptr, nullptr);
    if (converted_length == 0)
    {
      return std::string();
    }
    return utf8_string;
  }

  // Converts the given UTF-8 string to UTF-16.
  std::wstring Utf16FromUtf8(const std::string &utf8_string)
  {
    if (utf8_string.empty())
    {
      return std::wstring();
    }
    int target_length =
        ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
                              static_cast<int>(utf8_string.length()), nullptr, 0);
    if (target_length == 0)
    {
      return std::wstring();
    }
    std::wstring utf16_string;
    utf16_string.resize(target_length);
    int converted_length =
        ::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
                              static_cast<int>(utf8_string.length()),
                              utf16_string.data(), target_length);
    if (converted_length == 0)
    {
      return std::wstring();
    }
    return utf16_string;
  }

  const flutter::EncodableValue *ValueOrNull(const flutter::EncodableMap &map, const char *key)
  {
    auto it = map.find(flutter::EncodableValue(key));
    if (it == map.end())
    {
      return nullptr;
    }
    return &(it->second);
  }

  class PlatformProxyPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    PlatformProxyPlugin();

    virtual ~PlatformProxyPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void PlatformProxyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "platform_proxy",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<PlatformProxyPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  PlatformProxyPlugin::PlatformProxyPlugin() {}

  PlatformProxyPlugin::~PlatformProxyPlugin() {}

  void PlatformProxyPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("getPlatformProxy") == 0)
    {
      YSFPPProxyResolver resolver;
      std::ostringstream version_stream;
      const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      const auto *url = std::get_if<std::string>(ValueOrNull(*arguments, "url"));
      if (IsWindows10OrGreater())
      {
        version_stream << resolver.resolveProxiesAsJson(Utf16FromUtf8(*url));
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace

void PlatformProxyPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  PlatformProxyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

void ParseLpszProxy(std::wstring lpszProxy, std::vector<YSFPPProxy> &proxies, std::wstring urlScheme)
{
  std::wsmatch m;
  // This regular expression has a high probability of responding to the proxy configuration format supported on Windows.
  // It seems that the user name and password required by the proxy cannot be directly configured in the url on Windows, so it can be ignored
  std::wregex rx(L"([a-z0-9\\u00a1-\\uffff]+(?:\\.(?:[a-z0-9\\u00a1-\\uffff]-*)*[a-z0-9\\u00a1-\\uffff]+)*\\.[a-z0-9\\u00a1-\\uffff]{1,})(?::(\\d{2,5}))?");
  while (std::regex_search(lpszProxy, m, rx))
  {
    std::wstring host = m[1].str();
    std::wstring port = m[2].str();
    // I think the urlScheme here should not be the urlScheme of the visited url,
    // but the urlScheme of the proxy configuration, but it used to be the same for the time being
    proxies.push_back(YSFPPProxy::YSFPPProxy(host, port, L"", L"", urlScheme));
    lpszProxy = m.suffix().str();
  }
}

std::vector<YSFPPProxy> YSFPPProxyResolver::resolveProxies(std::wstring url)
{
  std::vector<YSFPPProxy> proxies;
  URL_COMPONENTS urlComp;
  std::wstring urlScheme;

  // Initialize the URL_COMPONENTS structure.
  ZeroMemory(&urlComp, sizeof(urlComp));
  urlComp.dwStructSize = sizeof(urlComp);

  // Set required component lengths to non-zero
  // so that they are cracked.
  urlComp.dwSchemeLength = (DWORD)-1;
  urlComp.dwHostNameLength = (DWORD)-1;
  urlComp.dwUrlPathLength = (DWORD)-1;
  urlComp.dwExtraInfoLength = (DWORD)-1;

  if (!WinHttpCrackUrl(url.c_str(), (DWORD)wcslen(url.c_str()), 0, &urlComp))
  {
    return proxies;
  }

  if (urlComp.nScheme == INTERNET_SCHEME_HTTP)
  {
    urlScheme = L"http";
  }
  else
  {
    urlScheme = L"https";
  }

  HINTERNET hHttpSession = WinHttpOpen(L"WinHTTP Flutter Platform Proxy Version/0.1",
                                       WINHTTP_ACCESS_TYPE_NO_PROXY,
                                       WINHTTP_NO_PROXY_NAME,
                                       WINHTTP_NO_PROXY_BYPASS,
                                       0);

  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG ProxyConfig = {};
  WINHTTP_AUTOPROXY_OPTIONS AutoProxyOptions = {};
  WINHTTP_PROXY_INFO ProxyInfo = {};

  if (WinHttpGetIEProxyConfigForCurrentUser(&ProxyConfig))
  {
    if (ProxyConfig.lpszAutoConfigUrl)
    {
      AutoProxyOptions.dwFlags = WINHTTP_AUTOPROXY_CONFIG_URL;
      AutoProxyOptions.lpszAutoConfigUrl = ProxyConfig.lpszAutoConfigUrl;
    }
    else if (ProxyConfig.fAutoDetect)
    {
      AutoProxyOptions.dwFlags = WINHTTP_AUTOPROXY_AUTO_DETECT;
      AutoProxyOptions.dwAutoDetectFlags = WINHTTP_AUTO_DETECT_TYPE_DHCP | WINHTTP_AUTO_DETECT_TYPE_DNS_A;
    }

    if (WinHttpGetProxyForUrl(hHttpSession,
                              url.c_str(),
                              &AutoProxyOptions,
                              &ProxyInfo))
    {
      if (ProxyInfo.lpszProxy)
      {
        ParseLpszProxy(ProxyInfo.lpszProxy, proxies, urlScheme);
      }
    }

    if (ProxyInfo.lpszProxy != NULL)
      GlobalFree(ProxyInfo.lpszProxy);
    if (ProxyInfo.lpszProxyBypass != NULL)
      GlobalFree(ProxyInfo.lpszProxyBypass);

    WinHttpCloseHandle(hHttpSession);

    if (ProxyConfig.lpszProxy)
    {
      if (ProxyConfig.lpszProxyBypass)
      {
        std::wstring bypass = ProxyConfig.lpszProxyBypass;
        if (bypass.find(urlComp.lpszHostName) == -1)
        {
          ParseLpszProxy(ProxyConfig.lpszProxy, proxies, urlScheme);
        }
      }
      else
      {
        ParseLpszProxy(ProxyConfig.lpszProxy, proxies, urlScheme);
      }
    }
  }

  return proxies;
}

std::string YSFPPProxyResolver::resolveProxiesAsJson(std::wstring url)
{
  std::vector<YSFPPProxy> proxies = this->resolveProxies(url);
  std::wstring result = L"[";

  for (std::vector<YSFPPProxy>::iterator it = proxies.begin(); it != proxies.end(); ++it)
  {
    result = result + (*it).json();
    if (it != --proxies.end())
    {
      result = result + L",";
    }
  }
  result = (result + L"]");

  int len;
  int slength = (int)result.length() + 1;
  len = WideCharToMultiByte(CP_ACP, 0, result.c_str(), slength, 0, 0, 0, 0);
  char *buf = new char[len];
  WideCharToMultiByte(CP_ACP, 0, result.c_str(), slength, buf, len, 0, 0);
  std::string r(buf);
  delete[] buf;
  return r;
}

YSFPPProxy::YSFPPProxy(std::wstring host, std::wstring port, std::wstring user, std::wstring password, std::wstring type)
{
  this->host = host;
  this->port = port;
  this->user = user;
  this->password = password;
  this->type = type;
}

std::wstring YSFPPProxy::json()
{
  std::wstring json = L"{";
  json = json + L"\"host\":\"" + host + L"\"";
  json = json + L",";
  json = json + L"\"port\":\"" + port + L"\"";
  json = json + L",";
  json = json + L"\"user\":\"" + user + L"\"";
  json = json + L",";
  json = json + L"\"password\":\"" + password + L"\"";
  json = json + L",";
  json = json + L"\"type\":\"" + type + L"\"";
  json = json + L"}";
  return json;
}