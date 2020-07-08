/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

namespace Caffeine {
    public class Countdown : Object {
        private int base_duration;
        private int64 start_time;

        public Countdown (int base_duration) {
            this.base_duration = base_duration;
        }

        public void start () {
            start_time = Utils.get_real_time_seconds ();
        }

        public void continue () {
            start_time = Utils.get_real_time_seconds ();
        }

        public int get_time_elapsed () {
            int time_elapsed = (int) (Utils.get_real_time_seconds () - start_time);

            return int.max (0, time_elapsed);
        }

        public int get_time_remaining () {
            int time_remaining = base_duration - get_time_elapsed ();

            return int.max (0, time_remaining);
        }

        public void set_base_duration (int base_duration) {
            this.base_duration = base_duration;
        }

        public bool is_finished () {
            return get_time_remaining () == 0;
        }

    }
}
