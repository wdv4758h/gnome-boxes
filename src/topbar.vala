// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

public enum Boxes.TopbarPage {
    COLLECTION,
    SELECTION,
    WIZARD,
    PROPERTIES,
    DISPLAY
}

[GtkTemplate (ui = "/org/gnome/Boxes/ui/topbar.ui")]
private class Boxes.Topbar: Gtk.Stack, Boxes.UI {
    private const string[] page_names = { "collection", "selection", "wizard", "properties", "display" };

    public UIState previous_ui_state { get; protected set; }
    public UIState ui_state { get; protected set; }
    [GtkChild]
    public PropertiesToolbar props_toolbar;

    [GtkChild]
    private CollectionToolbar collection_toolbar;
    [GtkChild]
    private SelectionToolbar selection_toolbar;
    [GtkChild]
    private DisplayToolbar display_toolbar;
    [GtkChild]
    public WizardToolbar wizard_toolbar;

    private AppWindow window;

    // Clicks the appropriate back button depending on the ui state.
    public void click_back_button () {
        switch (window.ui_state) {
        case UIState.PROPERTIES:
            break;
        case UIState.CREDS:
            collection_toolbar.click_back_button ();
            break;
        case UIState.WIZARD:
            wizard_toolbar.click_back_button ();
            break;
        }
    }

    // Clicks the appropriate forward button dependent on the ui state.
    public void click_forward_button () {
        wizard_toolbar.click_forward_button ();
    }

    // Clicks the appropriate cancel button dependent on the ui state.
    public void click_cancel_button () {
        switch (window.ui_state) {
        case UIState.COLLECTION:
            if (window.selection_mode)
                window.selection_mode = false;
            return;
        case UIState.WIZARD:
            wizard_toolbar.cancel_btn.clicked ();
            return;
        }
    }

    public void click_new_button () {
        if (window.ui_state == UIState.COLLECTION)
            collection_toolbar.click_new_button ();
    }

    public void click_search_button () {
        if (window.ui_state == UIState.COLLECTION)
            collection_toolbar.click_search_button ();
    }

    public string? _status;
    public string? status {
        get { return _status; }
        set {
            _status = value;
            collection_toolbar.set_title (_status??"");
            display_toolbar.set_title (_status??"");
        }
    }

    private TopbarPage _page;
    public TopbarPage page {
        get { return _page; }
        set {
            _page = value;

            visible_child_name = page_names[value];
        }
    }

    construct {
        notify["ui-state"].connect (ui_state_changed);

        transition_type = Gtk.StackTransitionType.CROSSFADE; // FIXME: Why this won't work from .ui file?
    }

    public void setup_ui (AppWindow window) {
        this.window = window;

        window.notify["selection-mode"].connect (() => {
            // FIXME: Usage of 'this' is a work around for https://bugzilla.gnome.org/show_bug.cgi?id=734877
            page = this.window.selection_mode ?
                TopbarPage.SELECTION : page = TopbarPage.COLLECTION;
        });

        var toolbar = window.display_page.toolbar;
        toolbar.bind_property ("title", display_toolbar, "title", BindingFlags.SYNC_CREATE);
        toolbar.bind_property ("subtitle", display_toolbar, "subtitle", BindingFlags.SYNC_CREATE);

        collection_toolbar.setup_ui (window);
        selection_toolbar.setup_ui (window);
        display_toolbar.setup_ui (window);
        props_toolbar.setup_ui (window);
    }

    private void ui_state_changed () {
        switch (ui_state) {
        case UIState.COLLECTION:
            page = TopbarPage.COLLECTION;
            break;

        case UIState.CREDS:
            page = TopbarPage.COLLECTION;
            break;

        case UIState.DISPLAY:
            page = TopbarPage.DISPLAY;
            break;

        case UIState.PROPERTIES:
            page = TopbarPage.PROPERTIES;
            break;

        case UIState.WIZARD:
            page = TopbarPage.WIZARD;
            break;

        default:
            break;
        }
    }
}
