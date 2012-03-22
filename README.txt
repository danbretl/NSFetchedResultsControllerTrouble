UPDATE: RESOLVED. I've fixed the problem by explicitly recreating the NSFetchedResultsController when switching between Gallery modes (between "Alphabetical" and "Recent"). (I've committed this successful change to this sample project.) I think actually I could get away with only resetting the FRC's NSFetchRequest rather than the entire controller, but either way, it's fixed now.

--- --- --- --- ---

UPDATE: I have narrowed the bug down and found that it now only occurs when the app is launched (not multitask-opened, but actually launched fresh) with the Gallery in "Alphabetical" mode. If it launches in "Recent" mode, the table view updates beautifully. But if it launches in "Alphabetical" mode, and you then switch to "Recent" mode, while the table view will be ordered correctly on the switch, it will not stay ordered correctly on data updates.

--- --- --- --- ---

This is a heavily stripped down version of a basic photo sharing app that I am currently developing. Each Photo is attached to a Feeling and a User. The most basic general view (the one visible in this version) is the Gallery. Here, you can view all Feelings, and for each Feeling, the 10 most recent Photos. There are two Gallery modes - "Alphabetical" and "Recent". When in "Alphabetical" mode, the Feelings are sorted alphabetically by the Feeling word. When in "Recent" mode, the Feelings are sorted by "most recently added to", meaning the Feeling that has had a Photo added to it most recently is at the top of the list.

My trouble is that the table is not responding to updates properly in "Recent" mode. It seems that NSFetchedResultsController is not responding to data updates correctly. Rows are not reordered properly, and sometimes a row that just moved to the top will take up both the first and second rows. (That second bug seems to have been taken care of by switching from "...configureCell..." to "...tableView reloadRows..." on NSFetchedResultsChangeUpdate.) What is confusing is that while the NSFetchedResultsController data prints as it should (with the newly updated "most recently added to" dates for the Feelings), it did not send the right delegate callbacks. (Specifically, it often reports an "...Update" instead of a "...Move".)

Of course, if you force the NSFetchedResultsController to explicitly refetch and then reload the table (by switching from "Recent" to "Alphabetical" and back again, for example), everything displays as it should (until you pull in new Photos again). So clearly, the data itself is not the problem, but the NSFetchedResultsController's monitoring / reporting on the changes in that data.

--- --- --- --- ---

The backend data is hosted and served up by Parse.com, though that shouldn't really effect anything. If you feel a peek into the Parse database is necessary, please let me know.

--- --- --- --- ---

You can reach me at dbretl@abextratech.com