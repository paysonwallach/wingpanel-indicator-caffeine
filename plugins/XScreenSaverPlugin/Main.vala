class Caffeine.Plugins.XScreenSaver : Peas.ExtensionBase, Peas.Activatable {
    private uint source_id = 0U;
    private int timeout_duration = 0;
    private int timeout_offset = -5;
    private File xscreensaver_preferences_file;

    public Object object { owned get; construct; }

    public XScreenSaver () {
        Object ();
    }

    construct {
        xscreensaver_preferences_file = File.new_build_filename (
            Environment.get_home_dir (), ".xscreensaver");

        if (!xscreensaver_preferences_file.query_exists ())
            error ("~/.xscreensaver not found.");

        var xscreensaver_preferences_file_monitor = xscreensaver_preferences_file.monitor_file (FileMonitorFlags.NONE, null);

        xscreensaver_preferences_file_monitor.changed.connect ((src, dest, event) => {
            if (event == FileMonitorEvent.CHANGED)
                on_xscreensaver_preferences_file_updated ();
        });

        on_xscreensaver_preferences_file_updated ();

        this.notify["timeout_duration"].connect (() => {
            if (source_id == 0U)
                deactivate_screensaver ();
        });
    }

    public void activate () {
        deactivate_screensaver ();
    }

    public void deactivate () {
        if (source_id != 0U) {
            Source.remove (source_id);
            source_id = 0U;
        }
    }

    public void update_state () {}

    private void deactivate_screensaver (int? interval = null) {
        if (interval == null)
            interval = timeout_duration;

        if (source_id != 0U)
            Source.remove (source_id);

        source_id = Timeout.add_seconds (interval + timeout_offset, () => {
            var success = false;
            string[] spawn_args = {"xscreensaver-command", "-deactivate"};
            string[] spawn_env = Environ.get ();

            try {
                Process.spawn_sync (
                    Environment.get_home_dir (),
                    spawn_args,
                    spawn_env,
                    SpawnFlags.SEARCH_PATH,
                    null,
                    null
                );

                success = true;
            } catch (Error err) {
                error (@"unable to spawn process");
            }

            return success;
        });
    }

    private void on_xscreensaver_preferences_file_updated () {
        try {
            var dis = new DataInputStream (
                xscreensaver_preferences_file.read ());

            string line;
            while ((line = dis.read_line (null)) != null) {
                string[] preference = line.split (":", 2);
                unowned string key = preference[0];

                if (key.strip () == "timeout") {
                    int timeout_duration = -1;
                    string[] time = preference[1].split(":");

                    for (int i = 0; i < time.length; i++)
                        timeout_duration += int.parse (time[i].strip ()) * (i == (time.length - 1) ? 1 : 60);

                    if (timeout_duration != -1)
                        this.timeout_duration = timeout_duration;

                    break;
                }
            }
        } catch (Error err) {
            error ("unable to parse preferences file");
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    Peas.ObjectModule object_module = module as Peas.ObjectModule;

    object_module.register_extension_type (
        typeof (Peas.Activatable),
        typeof (Caffeine.Plugins.XScreenSaver)
    );
}
