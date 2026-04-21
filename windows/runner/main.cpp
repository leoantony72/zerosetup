#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // ── Single Instance & Deep Link Handling ──────────────────────────────────
  const wchar_t* mutex_name = L"zerosetup_app_mutex";
  HANDLE hMutex = CreateMutex(NULL, TRUE, mutex_name);
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    // Another instance is running. Try to find its window.
    HWND hwnd = FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"zerosetup");
    if (hwnd) {
      // Pass the command line to the existing instance
      std::vector<std::string> args = GetCommandLineArguments();
      if (!args.empty()) {
        // We use WM_COPYDATA to send the URL to the main window
        COPYDATASTRUCT cds;
        cds.dwData = 1; // Custom ID for URI
        cds.cbData = static_cast<DWORD>(args[0].size() + 1);
        cds.lpData = const_cast<char*>(args[0].c_str());
        SendMessage(hwnd, WM_COPYDATA, (WPARAM)hwnd, (LPARAM)&cds);
      }
      // Bring the existing window to front
      ShowWindow(hwnd, SW_RESTORE);
      SetForegroundWindow(hwnd);
    }
    if (hMutex) CloseHandle(hMutex);
    return EXIT_SUCCESS;
  }
  // ─────────────────────────────────────────────────────────────────────────

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"zerosetup", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (hMutex) {
    ReleaseMutex(hMutex);
    CloseHandle(hMutex);
  }
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
