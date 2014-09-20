LockBox
=======

I was bored, so I wrote a little BLE screen locker / unlocker in Swift.
The code is horrible and needs refactoring and cleanup, since I was moving things around.
The UI is even worse.

TODO:
- Clean up the object model so we're not pulling the AppDelegate around everywhere
- Fix up the reconnect logic when the dongle goes out of range
- Persist the selected BT object and reuse on login

Icons came from: http://www.adiumxtras.com/index.php?a=xtras&xtra_id=6946
