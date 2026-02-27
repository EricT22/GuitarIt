Refactored tuner math into its own class and bound audio capture to the on/off switch in tuner, tested for functionality (~1hr 30 min)

Using MIDI to calculate the closest note and cent offset, updating UI accordingly (~1hr 30 min)
UI tuner updates (red/yellow/green depending on how close the frequency is) (~30 min)

Researching how to connect w/ Lyria RealTime using Google Firebase (~1hr)

Exponential smoothing for tuner to avoid big jumps (~45 min)

Created firebase app on firebase console & connected it to SwiftUI App (~30 min)

Realized that I'd need to put a cc on file to use cloud functions and it would cap at around ~5,000-10,000 calls/month
Pivoting to Cloudflare Workers as I can call its cloud functions ~10,000,000 times/month as long as CPU time is less than 10ms
Which works b/c the fetch(url) does not count

Researched cloudflare workers (~1 hour)

Researching Lyria RealTime input and output in Google AI Studio, as documentation is limited given its an experimental model (~2 hours)

Debugged tuner, implemented spike threshold and tweaked exponential smoothing to make it feel more natural - TLDR tuner done (~45 min)
