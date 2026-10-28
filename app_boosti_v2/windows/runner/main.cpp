#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // ── INSTANCIA ÚNICA ──────────────────────────────────────────────
  // Presionar el .exe varias veces hoy abre varias instancias de la
  // app (cada una abriría su propio Isar sobre la MISMA carpeta de
  // datos: riesgo de corrupción y de doble venta). El mutex con nombre
  // lo corta a nivel del runner, ANTES de abrir Isar que es donde
  // importa. Si la instancia ya existe, se le saca al frente y esta
  // sale con éxito (no un error raro).
  //
  // `Local\` scope: una instancia por sesión de usuario. El mutex se
  // libera solo cuando el proceso muere, incluso en un crash.
  HANDLE app_mutex = ::CreateMutexW(nullptr, TRUE,
                                    L"Local\\Boosti_POS_InstanciaUnica");
  if (app_mutex != nullptr && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND existente = ::FindWindowW(nullptr, L"BOOSTI POS");
    if (existente != nullptr) {
      ::ShowWindow(existente, SW_RESTORE);
      ::SetForegroundWindow(existente);
    }
    ::CloseHandle(app_mutex);
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"BOOSTI POS", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
