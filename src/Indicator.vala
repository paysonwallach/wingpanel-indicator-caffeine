/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

public class Caffeine.Indicator : Wingpanel.Indicator {
    private Wingpanel.Widgets.OverlayIcon icon;

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
        icon = new Wingpanel.Widgets.OverlayIcon ("caffeine-cup-empty");

        var settings = new Settings ("com.paysonwallach.caffeine");

        this.enabled = false;
        this.power_settings = new Settings ("org.gnome.settings-daemon.plugins.power");
        this.session_settings = new Settings ("org.gnome.desktop.session");
        this.dpms_settings = new Settings ("io.elementary.dpms");

        this.settings.bind ("ac-type", this, "sleep_settings_ac", SettingsBindFlags.DEFAULT);
        this.settings.bind ("bat-type", this, "sleep_settings_bat", SettingsBindFlags.DEFAULT);
        this.settings.bind ("dim-on-idle", this, "idle_dim", SettingsBindFlags.DEFAULT);
        this.settings.bind ("session-timeout", this, "session_timeout", SettingsBindFlags.DEFAULT);
        this.settings.bind ("standby-time", this, "standby_time", SettingsBindFlags.DEFAULT);
        this.settings.bind ("enabled", this, "enabled", SettingsBindFlags.DEFAULT);

        this.visible = true;
    }

    public override Gtk.Widget get_display_widget () {
        return icon;
    }

    public override Gtk.Widget? get_widget () {
        return null;
    }

    public override void opened () {
        this.close ();

        if (this.enabled) {
            icon.set_main_icon_name ("caffeine-cup-empty");

            // restore settings
            power_settings.set_string("sleep-inactive-ac-type", this.sleep_settings_ac);
            power_settings.set_string("sleep-inactive-battery-type", this.sleep_settings_bat);
            power_settings.set_boolean("idle-dim", this.idle_dim);
            session_settings.set_uint("idle-delay", this.session_timeout);
            dpms_settings.set_int("standby-time", this.standby_time);

            this.enabled = false;
        } else {
            icon.set_main_icon_name ("caffeine-cup-full");

            // store old sleep settings
            this.sleep_settings_ac = power_settings.get_string("sleep-inactive-ac-type");
            this.sleep_settings_bat = power_settings.get_string("sleep-inactive-battery-type");
            this.idle_dim = power_settings.get_boolean("idle-dim");
            this.session_timeout = session_settings.get_uint("idle-delay");
            this.standby_time = dpms_settings.get_int("standby-time");

            // disable sleep settings and session idle
            power_settings.set_string("sleep-inactive-ac-type", "nothing");
            power_settings.set_string("sleep-inactive-battery-type", "nothing");
            power_settings.set_boolean("idle-dim", false);
            session_settings.set_uint("idle-delay", 0);
            dpms_settings.set_int("standby-time", 0);

            this.enabled = true;
        }
    }

    public override void closed () {}
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {

    /* Check which server has loaded the plugin */
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our sample indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    var indicator = new Caffeine.Indicator ();

    return indicator;
}
