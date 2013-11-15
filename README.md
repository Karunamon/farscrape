Farscrape
=========

A script which logs into a Wells Fargo (North America only, sorry) account page
and retrieves acount available balances.

I wrote this out of annoyance that all of the services out there that go
through third party data brokers return incomplete or out of date information.

The only way to get the freshest data is to log into the website or use the
(utterly crap) mobile app which doesn't remember passwords, doesn't stay
logged in, and so on.

A warning
---------
In case there was any doubt in your mind, this little script is not owned by,
created by, sanctioned by, or even *LIKED* by Wells Fargo Bank NA, Inc.

In fact, even using this is against some kind of TOS. If you don't go
crazy with how often you check, you'll probably be fine (since every time
you run this, it logs in) - but still.

Legalese:

This software is made available in the hopes it will be useful. That said,
it is provided "AS IS," without warranties of any kind. The author(s) expressly
disclaim any representations and warranties, including without limitation, the
implied warranties of merchantability and fitness for a particular purpose.

**You have been warned**.


Usage
-----
Edit the script, put your username and password in the $wf_username and
$wf_password vars. I suggest you base64 encode these as minor security, this
way anyone that comes up behind you can't just see your login credentials.

Run the script - it should log in to the account summary page and present you
with a list of cash account balances.