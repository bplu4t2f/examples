package fen_tool

import log "core:log"
import win "core:sys/windows"

about_show_dialog :: proc(owner: win.HWND) {
	hInstance := cast(win.HINSTANCE)win.GetModuleHandleW(nil)
	win.DialogBoxW(hInstance, "IDD_ABOUT", owner, about_proc)
}

about_proc :: proc "system" (hdlg: win.HWND, msg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) -> win.INT_PTR {
	switch msg {
	case win.WM_INITDIALOG:
		return 1

	case win.WM_COMMAND:
		context = window_context_tls
		id := win.LOWORD(wparam)
		nc := win.HIWORD(wparam)
		log.debugf("About WM_COMMAND: %v %v", id, nc)
		switch id
		{
		case win.IDOK:
			win.EndDialog(hdlg, 0)
			return 1
		case win.IDCANCEL:
			win.EndDialog(hdlg, 0)
			return 1
		}

	case win.WM_PAINT:
		ps: win.PAINTSTRUCT
		hdc := win.BeginPaint(hdlg, &ps)
		defer win.EndPaint(hdlg, &ps)

		hInstance := cast(win.HINSTANCE)win.GetModuleHandleW(nil)
		hbitmap := win.LoadImageW(hInstance, "IDB_ABOUT", win.IMAGE_BITMAP, 0, 0, win.LR_CREATEDIBSECTION)
		defer win.DeleteObject(auto_cast hbitmap)
		bm: win.BITMAP
		win.GetObjectW(hbitmap, size_of(bm), &bm)
		
		hdc_src := win.CreateCompatibleDC(hdc)
		defer win.DeleteDC(hdc_src)
		previous_bitmap := cast(win.HBITMAP)win.SelectObject(hdc_src, auto_cast hbitmap)
		defer win.SelectObject(hdc_src, auto_cast previous_bitmap)
		
		transparency_key := win.GetPixel(hdc_src, 0, 0)

		win.TransparentBlt(
			hdc, 0, 0, bm.bmWidth, bm.bmHeight,
			hdc_src, 0, 0, bm.bmWidth, bm.bmHeight,
			transparency_key,
		)	
	}

	return 0
}
