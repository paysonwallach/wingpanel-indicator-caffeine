/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

namespace Caffeine {
    public class Utils {
        public const int MICROSECONDS_IN_SECONDS = 1000 * 1000;

        public inline static int64 get_real_time_seconds () {
            return get_real_time () / MICROSECONDS_IN_SECONDS;
        }

        public inline static int64 get_monotonic_time_seconds () {
            return get_monotonic_time () / MICROSECONDS_IN_SECONDS;
        }

    }
}
