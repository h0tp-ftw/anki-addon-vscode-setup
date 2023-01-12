from aqt.gui_hooks import main_window_did_init


def on_main_window_did_init():
    print("Main window did init")


main_window_did_init.append(on_main_window_did_init)
