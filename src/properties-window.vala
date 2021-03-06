// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

private enum Boxes.PropsWindowPage {
    MAIN,
    TROUBLESHOOTING_LOG,
    FILE_CHOOSER,
}

[GtkTemplate (ui = "/org/gnome/Boxes/ui/properties-window.ui")]
private class Boxes.PropertiesWindow: Gtk.Window, Boxes.UI {
    public const string[] page_names = { "main", "troubleshoot_log", "file_chooser" };

    public delegate void FileChosenFunc (string path);

    public UIState previous_ui_state { get; protected set; }
    public UIState ui_state { get; protected set; }

    private PropsWindowPage _page;
    public PropsWindowPage page {
        get { return _page; }
        set {
            _page = value;

            view.visible_child_name = page_names[value];
            topbar.page = value;
        }
    }

    [GtkChild]
    public Gtk.Stack view;
    [GtkChild]
    public Properties properties;
    [GtkChild]
    public TroubleshootLog troubleshoot_log;
    [GtkChild]
    public Gtk.FileChooserWidget file_chooser;
    [GtkChild]
    public PropertiesToolbar topbar;
    [GtkChild]
    public Notificationbar notificationbar;

    private unowned AppWindow app_window;

    public PropertiesWindow (AppWindow app_window) {
        this.app_window = app_window;

        properties.setup_ui (app_window, this);
        topbar.setup_ui (app_window, this);

        set_transient_for (app_window);

        notify["ui-state"].connect (ui_state_changed);
    }

    public void show_troubleshoot_log (string log) {
        troubleshoot_log.view.buffer.text = log;
        page = PropsWindowPage.TROUBLESHOOTING_LOG;
    }

    public void show_file_chooser (owned FileChosenFunc file_chosen_func) {
        ulong activated_id = 0;
        activated_id = file_chooser.file_activated.connect (() => {
            var path = file_chooser.get_filename ();
            file_chosen_func (path);
            file_chooser.disconnect (activated_id);

            page = PropsWindowPage.MAIN;
        });
        page = PropsWindowPage.FILE_CHOOSER;
    }

    public void copy_troubleshoot_log_to_clipboard () {
        var log = troubleshoot_log.view.buffer.text;
        var clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);

        clipboard.set_text (log, -1);
    }

    public void revert_state () {
        if ((app_window.current_item as Machine).state != Machine.MachineState.RUNNING &&
             app_window.previous_ui_state == UIState.DISPLAY)
            app_window.set_state (UIState.COLLECTION);
        else
            app_window.set_state (app_window.previous_ui_state);

        page = PropsWindowPage.MAIN;
    }

    private void ui_state_changed () {
        properties.set_state (ui_state);

        visible = (ui_state == UIState.PROPERTIES);
    }

    [GtkCallback]
    private bool on_key_pressed (Widget widget, Gdk.EventKey event) {
        var default_modifiers = Gtk.accelerator_get_default_mod_mask ();
        var direction = get_direction ();

        if (((direction == Gtk.TextDirection.LTR && // LTR
              event.keyval == Gdk.Key.Left) ||      // ALT + Left -> back
             (direction == Gtk.TextDirection.RTL && // RTL
              event.keyval == Gdk.Key.Right)) &&    // ALT + Right -> back
            (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            topbar.click_back_button ();

            return true;
        } else if (event.keyval == Gdk.Key.Escape) { // ESC -> back
            revert_state ();

            return true;
        }

        return false;
    }

    [GtkCallback]
    private bool on_delete_event () {
        notificationbar.dismiss_all ();
        revert_state ();

        return true;
    }
}
