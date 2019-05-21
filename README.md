# tracking_app

### Track your location (continusly), add and save to sqlite
- add markers to to track points
- add infos to track markers
- add markers with coordinates not belonging to track

### Load a gpx track
### Save a single point with image, video, voice msg or description

### Tracking
Add coordinates at changed of distance.
This coordinates are insert into db -> trackCoord.
When leaving tracking page save coordinates as gpx file.
During tracking all coords are saved in trackCoord table - to many!
Reduce: save only coords with trackItems attached.

### Track
Track page displays track and track items.
Add, Delete, Move track points
Add Item to track points
Display modes:
    view track + track points
    view track only

Enable / disable current position

### Follow Track
1. Load coordinates from gpx file
2. Display track as polyline
3. Online and Offline mode
4. Show current position
5. Highlight track segments
6. Track info: distance, distance between track points

The track can't be modified, no writing to db or storage.
Minimal power consumtion
In Offline mode - no internet connection necessary, perhaps Flight Mode possible?

### Record Track
1. Subscribe to location coordinates stream
2. Add TrackItems at coordinates
3. Show recorded track on map
4. Show current position
5. Save track to db
6. Save track as gpx file


###
