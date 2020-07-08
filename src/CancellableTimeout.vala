/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

namespace Caffeine {
    public class CancellableTimeout : Object {
        public delegate void TimeoutCallback (CancellableTimeout timeout, int delta_millisec);

        private unowned TimeoutCallback timeout_callback;
        private uint source_id;
        private int frequency;
        private int64 last_time;

        public CancellableTimeout (TimeoutCallback callback, int frequency) {
            this.timeout_callback = callback;
            this.frequency = frequency;
        }

        private bool timeout_wrapper () {
            int64 now = get_monotonic_time ();
            int64 time_delta = now - last_time;

            last_time = now;
            timeout_callback (this, (int) (time_delta / 1000));

            return true;
        }

        public void run_once () {
            timeout_wrapper ();
        }

        public void start () {
            if (is_running ())
                Source.remove (source_id);

            last_time = get_monotonic_time ();
            source_id = Timeout.add_seconds (frequency, timeout_wrapper);
        }

        public void set_frequency (int frequency) {
            this.frequency = frequency;

            if (is_running ())
                start ();
        }

        public void cancel () {
            if (is_running ()) {
                Source.remove (source_id);
                source_id = 0;
            }
        }

        public bool is_running () {
            return source_id != 0;
        }

    }
}
