#if DEBUG
import Foundation

extension ScreenshotSamples {
    static let englishNotes = [
        SampleNote(
            title: "Retest Study Plan",
            text: """
            # Retest Study Plan

            The retest is on **Friday**. This time, everyone passes!

            ## This week
            - [x] Maths practice test with Hifumi
            - [x] Essay outline with Hanako
            - [ ] Vocabulary drills for Koharu
            - [ ] Field manual review with Azusa

            ## Study sessions
            1. Monday after lessons, Classroom 3
            2. Wednesday lunch, the library
            3. Thursday evening, *quiet hours only*

            ## Notes
            - Koharu does better with short breaks
            - Hanako finished the reading already, so she can tutor
            - Keep the Peroro goods out of sight during the exam

            > Vanitas vanitatum, et omnia vanitas.
            > But we'll study anyway. — Azusa
            """,
            minutesAgo: 12
        ),
        SampleNote(
            title: "Supply Run with Saori",
            text: """
            # Supply Run with Saori

            Meeting Saori at Classroom 7 on **Thursday, 9:30**.

            - [x] Rations for a week
            - [x] Blankets for everyone
            - [ ] First aid kit for Atsuko
            - [ ] Spare magazines for Misaki
            - [ ] Something sweet for Hiyori
            """,
            minutesAgo: 95
        ),
        SampleNote(
            title: "Tea Meeting Minutes",
            text: """
            # Tea Meeting Minutes

            Present: Nagisa, Mika, Seia and Sensei.

            ## Agenda
            1. Festival budget
            2. Patrol schedule with Tsurugi
            3. Roll cakes, again
            """,
            minutesAgo: 60 * 26
        ),
        SampleNote(
            title: "Peroro Goods Wishlist",
            text: """
            # Peroro Goods Wishlist

            For Hifumi's birthday, keep it a secret!

            - [ ] Limited edition plush
            - [ ] Peroro tote bag
            - [x] Keychain set
            """,
            minutesAgo: 60 * 50
        ),
        SampleNote(
            title: "Festival Ideas",
            text: """
            # Festival Ideas

            - Tea stall run by Nagisa and Mika
            - Shooting gallery, ask Azusa for targets
            - Movie screening with Saori and Hiyori
            """,
            minutesAgo: 60 * 75
        )
    ]
}
#endif
