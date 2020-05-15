/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

public class Caffeine.Indicator : Wingpanel.Indicator {
    private struct Durations {
        int[] quantities;
        Units unit;

        Durations (Units unit, int[] quantities) {
            this.quantities = quantities;
            this.unit = unit;
        }
    }

    private Durations minute_durations = Durations (
        Units.MINUTES, { 5, 10, 15, 20, 25, 30, 45 });
    private Durations hour_durations = Durations (
        Units.HOURS, { 1, 2, 3, 4, 5, 6, 9, 12, 24 });

    private Gtk.Image icon;
    private Gtk.Grid menu;

    private Gtk.Revealer? opened_submenu;
    private Gtk.Revealer? active_menubutton_parent;
    private MenuButton? active_menubutton;

    private Gtk.Revealer session_countdown_revealer;
    private Gtk.Button session_cancel_button;
    private Gtk.Label session_countdown_timer_label;

    private CountdownTimerController? countdown_timer_controller;

    private Settings settings;
    private Settings dpms_settings;
    private Settings power_settings;
    private Settings session_settings;

    public string sleep_settings_ac { get; set; }
    public string sleep_settings_bat { get; set; }
    public bool idle_dim { get; set; }
    public uint session_timeout { get; set; }
    public int standby_time { get; set; }
    public bool enabled { get; set; }

    public Indicator () {
        Object (
            code_name: "caffeine-indicator"
        );
    }

    construct {
        enabled = false;
        icon = new Gtk.Image.from_icon_name (
            "caffeine-cup-empty-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

        icon.button_press_event.connect (on_button_press);

        settings = new Settings ("com.paysonwallach.caffeine");
        power_settings = new Settings ("org.gnome.settings-daemon.plugins.power");
        session_settings = new Settings ("org.gnome.desktop.session");
        dpms_settings = new Settings ("io.elementary.dpms");

        settings.bind ("ac-type", this, "sleep_settings_ac", SettingsBindFlags.DEFAULT);
        settings.bind ("bat-type", this, "sleep_settings_bat", SettingsBindFlags.DEFAULT);
        settings.bind ("dim-on-idle", this, "idle_dim", SettingsBindFlags.DEFAULT);
        settings.bind ("session-timeout", this, "session_timeout", SettingsBindFlags.DEFAULT);
        settings.bind ("standby-time", this, "standby_time", SettingsBindFlags.DEFAULT);
        settings.bind ("enabled", this, "enabled", SettingsBindFlags.DEFAULT);

        construct_menu ();
        Notify.init ("Caffeine");

        visible = true;
    }

    public override Gtk.Widget get_display_widget () {
        return icon;
    }

    public override Gtk.Widget? get_widget () {
        return menu;
    }

    public override void opened () {
        if (active_menubutton_parent != null)
            active_menubutton_parent.set_reveal_child (true);
            opened_submenu = active_menubutton_parent;
    }

    public override void closed () {
        if (active_menubutton_parent != null)
            active_menubutton_parent.set_reveal_child (false);
        if (opened_submenu != null)
            opened_submenu.set_reveal_child (false);
            opened_submenu = null;
    }

    private void construct_menu () {
        int index = 1;

        menu = new Gtk.Grid ();
        session_countdown_revealer = new Gtk.Revealer ();
        session_cancel_button = new Gtk.Button.with_label ("End session");
        session_countdown_timer_label = new Gtk.Label ("");

        var session_countdown_grid = new Gtk.Grid ();
        var session_countdown_title_label = new Gtk.Label ("");

        session_countdown_title_label.set_markup ("Session enabled");
        session_countdown_title_label.get_style_context ()
            .add_class (Granite.STYLE_CLASS_H4_LABEL);

        session_countdown_title_label.halign = Gtk.Align.START;
        session_countdown_title_label.hexpand = true;
        session_countdown_title_label.margin = 10;
        session_countdown_title_label.margin_top = 6;
        session_countdown_title_label.margin_bottom = 2;

        session_countdown_timer_label.halign = Gtk.Align.START;
        session_countdown_timer_label.hexpand = true;
        session_countdown_timer_label.margin = 10;
        session_countdown_timer_label.margin_top = 0;
        session_countdown_timer_label.margin_bottom = 4;

        var session_cancel_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        session_cancel_button_box.set_border_width (6);
        session_cancel_button_box.pack_end (session_cancel_button);

        session_cancel_button.hexpand = false;

        session_cancel_button.get_style_context ()
            .add_class ("destructive-action");

        session_countdown_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);

        session_countdown_grid.attach (session_countdown_title_label, 0, 0);
        session_countdown_grid.attach (session_countdown_timer_label, 0, 1);
        session_countdown_grid.attach (session_cancel_button_box, 0, 2);
        session_countdown_grid.attach (new Wingpanel.Widgets.Separator (), 0, 3);

        session_countdown_revealer.add (session_countdown_grid);

        menu.attach (session_countdown_revealer, 0, 0);

        add_menu_button_with_duration (new InfiniteDuration (), menu, index++);

        menu.attach (new Wingpanel.Widgets.Separator (), 0, index++);

        Durations[] durations_list = { minute_durations, hour_durations };

        int list_index = 0;
        foreach (var durations in durations_list) {
            var submenu_index = 0;
            var submenu_container = new Gtk.Grid ();
            var button = new MenuButton (@"$(durations.unit.to_string ())");
            var revealer = new Gtk.Revealer ();
            var submenu = new Gtk.Grid ();

            button.get_style_context ()
                .add_class (Granite.STYLE_CLASS_H4_LABEL);
            button.clicked.connect (() => {
                if (opened_submenu == revealer) {
                    revealer.set_reveal_child (false);
                    opened_submenu = null;
                } else {
                    if (opened_submenu != null) {
                        opened_submenu.set_reveal_child (false);
                    }

                    revealer.set_reveal_child (true);
                    opened_submenu = revealer;
                }
            });

            revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
            revealer.add (submenu);

            foreach (var quantity in durations.quantities) {
                FiniteDuration duration;

                if (durations.unit == Units.MINUTES) {
                    duration = new MinuteDuration (quantity);
                } else {
                    duration = new HourDuration (quantity);
                }

                add_menu_button_with_duration (duration, submenu, submenu_index++);
            }

            if (list_index++ != durations_list.length - 1)
                submenu.attach (new Wingpanel.Widgets.Separator (), 0, submenu_index++);

            submenu_container.attach (button, 0, 0);
            submenu_container.attach (revealer, 0, 1);

            menu.attach (submenu_container, 0, index++);
        }
    }

    private void add_menu_button_with_duration (Duration duration, Gtk.Grid menu, int index) {
        var button = new MenuButton ("", "check-active-symbolic");

        if (duration.unit == Units.INDEFINITE) {
            button.set_caption (duration.to_string ());
        } else {
            string[] split = Regex.split_simple ("(\\d+)", duration.to_string ());

            var duration_label = new Gtk.Label (split[1]);

            int width;
            int height;
            Pango.Layout layout = duration_label.get_layout ().copy ();

            layout.set_markup ("000", -1);
            layout.get_pixel_size (out width, out height);

            duration_label.set_size_request (width, -1);
            duration_label.justify = Gtk.Justification.RIGHT;
            duration_label.xalign = 1.0f;

            var units_label = new Gtk.Label (split[2]);

            units_label.margin_end = 10;

            button.content_widget.attach (duration_label, 1, 0);
            button.content_widget.attach (units_label, 2, 0);
        }

        button.clicked.connect (() => {
            on_menu_button_clicked (button, duration);
        });
        button.set_image_visible (false);

        menu.attach (button, 0, index);
    }

    private void on_menu_button_clicked (MenuButton button, Duration duration) {
        active_menubutton_parent = opened_submenu;

        var start_new_session = false;

        if (active_menubutton != button) {
            start_new_session = true;
        }

        if (enabled) {
            session_cancel_button.clicked ();
        }

        if (!start_new_session) {
            return;
        }

        active_menubutton = button;

        enable ();
        show_notification (
            "Caffeine enabled",
            duration.notification_string ()
        );

        if (duration.unit == Units.INDEFINITE) {
            session_cancel_button.clicked.connect (() => {
                disable (false);
            });

            session_countdown_timer_label.set_markup (
                @"<small>$(duration.time_remaining_string ())</small>"
            );
        } else {
            if (countdown_timer_controller == null)
                countdown_timer_controller = new CountdownTimerController ();

            countdown_timer_controller.duration = duration.quantity * duration.unit.to_seconds ();

            countdown_timer_controller.active_changed.connect (() => {
                session_countdown_timer_label.set_markup (
                    @"<small>Time remaining: $(duration.time_remaining_string (countdown_timer_controller.get_time_remaining ()))</small>"
                );
            });
            countdown_timer_controller.completed.connect (() => {
                disable ();
            });
            countdown_timer_controller.activate ();

            session_cancel_button.clicked.connect (() => {
                countdown_timer_controller.cancel ();
                disable (false);
            });

            session_countdown_timer_label.set_markup (
                @"<small>Time remaining: $(duration.time_remaining_string (countdown_timer_controller.duration - 1))</small>"
            );
        }

        session_countdown_revealer.set_reveal_child (true);
    }

    private void disable (bool notify_user = true) {
        // restore settings
        power_settings.set_string("sleep-inactive-ac-type", sleep_settings_ac);
        power_settings.set_string("sleep-inactive-battery-type", sleep_settings_bat);
        power_settings.set_boolean("idle-dim", idle_dim);
        session_settings.set_uint("idle-delay", session_timeout);
        dpms_settings.set_int("standby-time", standby_time);

        icon.icon_name = "caffeine-cup-empty-symbolic";

        session_countdown_revealer.set_reveal_child (false);

        if (active_menubutton != null) {
            active_menubutton.set_image_visible (false);

            active_menubutton = null;
        }

        if (active_menubutton_parent != null) {
            active_menubutton_parent = null;
        }

        if (notify_user)
            show_notification (
                "Caffeine disabled",
                "Your computer will resume sleeping normally."
            );

        enabled = false;
    }

    private void enable () {
        // store old sleep settings
        sleep_settings_ac = power_settings.get_string("sleep-inactive-ac-type");
        sleep_settings_bat = power_settings.get_string("sleep-inactive-battery-type");
        idle_dim = power_settings.get_boolean("idle-dim");
        session_timeout = session_settings.get_uint("idle-delay");
        standby_time = dpms_settings.get_int("standby-time");

        // disable sleep settings and session idle
        power_settings.set_string("sleep-inactive-ac-type", "nothing");
        power_settings.set_string("sleep-inactive-battery-type", "nothing");
        power_settings.set_boolean("idle-dim", false);
        session_settings.set_uint("idle-delay", 0);
        dpms_settings.set_int("standby-time", 0);

        icon.icon_name = "caffeine-cup-full-symbolic";

        active_menubutton.set_image_visible (true);

        enabled = true;
    }

    private bool on_button_press (Gdk.EventButton event) {
        if (event.button == Gdk.BUTTON_MIDDLE) {
            if (enabled) {
                countdown_timer_controller.cancel ();
                disable (false);
            } else {
                enable ();
                show_notification (
                    "Caffeine enabled",
                    "Your computer will not go to sleep."
                );
            }

            return Gdk.EVENT_STOP;
        }

        return Gdk.EVENT_PROPAGATE;
    }

    private void show_notification (string summary, string body) {
        try {
            new Notify.Notification (
                summary,
                body,
                null
            ).show ();
        } catch (Error err) {
            error (@"unable to show notification: $(err.message)");
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION)
        return null;

    var indicator = new Caffeine.Indicator ();

    return indicator;
}
