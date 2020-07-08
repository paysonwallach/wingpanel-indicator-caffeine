/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

namespace Caffeine {
    public enum Units {
        MINUTES,
        HOURS,
        INDEFINITE;

        public int? to_seconds () {
            switch (this) {
            case MINUTES:
                return 60;
            case HOURS:
                return 60 * MINUTES.to_seconds ();
            case INDEFINITE:
                return null;
            default:
                assert_not_reached ();
            }
        }

        public string to_string () {
            switch (this) {
            case MINUTES:
                return "Minutes";
            case HOURS:
                return "Hours";
            case INDEFINITE:
                return "Indefinite";
            default:
                assert_not_reached ();
            }
        }

    }

    public abstract class Duration {
        public int quantity;
        public Units unit;

        public abstract string to_string ();

        public abstract string notification_string ();

        public abstract string time_remaining_string (int time_remaining = 0);

    }

    public abstract class FiniteDuration : Duration {
        FiniteDuration (int quantity) {
            this.quantity = quantity;
        }

        public override string notification_string () {
            return @"Your computer will not go to sleep for $(to_string ()).";
        }

        public override string time_remaining_string (int time_remaining = 0) {
            return Granite.DateTime.seconds_to_time (time_remaining);
        }

    }

    public class InfiniteDuration : Duration {
        public InfiniteDuration () {
            this.quantity = -1;
            this.unit = Units.INDEFINITE;
        }

        public override string to_string () {
            return unit.to_string ();
        }

        public override string notification_string () {
            return "Your computer will not go to sleep.";
        }

        public override string time_remaining_string (int time_remaining = 0) {
            return "This session is not scheduled to end.";
        }

    }

    public class MinuteDuration : FiniteDuration {
        public MinuteDuration (int quantity) {
            base (quantity);
            this.unit = Units.MINUTES;
        }

        public override string to_string () {
            return @"$(quantity.to_string ()) $(unit.to_string ().down ())";
        }

    }

    public class HourDuration : FiniteDuration {
        public HourDuration (int quantity) {
            base (quantity);
            this.unit = Units.HOURS;
        }

        public override string to_string () {
            return (ngettext ("%u hour", "%u hours", quantity)).printf (quantity);
        }

    }
}
