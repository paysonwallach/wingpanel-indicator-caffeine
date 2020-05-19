/*
 * Caffeine
 *
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the GNU General Public License, version 3
 * (https://gnu.org/licenses/gpl.html)
 */

namespace Caffeine {
    public class CountdownTimerController : Object {
        public enum State {
            STOPPED,
            ACTIVE,
            INACTIVE
        }
        public State state { get; private set; }

        public int duration { get; set; }

        /**
         * The countdown clock has been activated and is actively counting down.
         */
        public signal void activated ();

        /**
         * The countdown clock has completed counting down.
         */
        public signal void completed ();

        /**
         * The countdown has been cancelled.
         */
        public signal void cancelled ();

        /**
         * The countdown clock's state has changed, such as the time remaining
         * has decremented.
         */
        public signal void active_changed ();

        protected Countdown duration_countdown;
        protected CancellableTimeout countdown_timeout;

        public CountdownTimerController () {
            state = State.INACTIVE;
            duration_countdown = new Countdown (duration);
            countdown_timeout = new CancellableTimeout (update_countdown, 1);

            notify["duration"].connect((s, p) => {
                duration_countdown.set_base_duration (duration);
            });

            activated.connect (on_activation);
            cancelled.connect (on_cancellation);
            completed.connect (on_completion);
        }

        public void activate () {
            state = State.ACTIVE;
            activated ();
        }

        public void cancel () {
            cancelled ();
        }

        public Json.Object serialize () {
            var object = new Json.Object ();

            object.set_int_member (
                "state", (int) state);
            object.set_int_member (
                "duration", duration_countdown.get_time_remaining ());

            return object;
        }

        public void deserialize (Json.Object data) {
            state = (State) data.get_int_member ("state");
            duration = (int) data.get_int_member ("duration");
        }

        private void on_activation () {
            duration_countdown.continue ();
            countdown_timeout.start ();
        }

        private void on_cancellation () {
            state = State.STOPPED;
            countdown_timeout.cancel ();
        }

        private void on_completion () {
            state = State.INACTIVE;
            countdown_timeout.cancel ();
        }

        public int get_time_remaining () {
            return duration_countdown.get_time_remaining ();
        }

        private void update_countdown (CancellableTimeout timeout, int delta_millisec) {
            if (duration_countdown.is_finished ()) {
                completed ();
            } else if (state == State.ACTIVE) {
                active_changed ();
            }
        }
    }
}
