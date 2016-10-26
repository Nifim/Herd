**Author:**  Nifim<br>
**Version:**  1.3.5<br>
**Date:** Oct. 25, 2016<br>

# Herd #

* Follows a PC, NPC, Pet, or an other targetable object in the game.
* **although unlikely this addon may appear bot like in the nature of the char movement**

----

**Abbreviation:** No abbreviated command line only //herd

#### Commands: ####
* 1. help - Displays this help menu.
* 2a. (s)hepherd - Will make all other boxs follow the box that sent this command
  - this is done by sending an ipc message containing the char ID
  - In the past I have seen unreliable communication using the ipc messaging, that said since 1.3.5 i have not seen these failures.
  - all box that recieve the ipc will state -- Sheperd is now: [CharatcerName]
* 2b. (s)hepherd [Name]- Will make all this box follow the character with givin name
  - this does not send an ipc message it is done by locating the requested char by name and retriving their ID it will not work if the char is not within the render area. 
* 3. (j)oin - Causes box to join the herd and follow the current shepherd
  - sends ipc message requesting id of the current shepherd
  - there can only ever be 1 shepherd
* 4. (l)eave - Causes box to leave the herd and follow the current shepherd
  - resets Shepherd to '' and Sheep to false
  - no ipc message is sent 
* 5. (r)elease - Causes all boxs to leave herd and cease following
  - sends ipc message commanding all boxs to perform //herd leave
  - maybe sent from any box (does not need to be master)

----

#### To do: ####
* Open settings to user.
  * roam distance
* Add Menu following functions
 * Home point
 * Way point
 * etc.
* Handle bug where in new shepherd's last location(where they stopped rendering) is deemed their current location for new sheep that can not actually see the shepherd
* Create job profiles 
  * this would have combat distances
  * reactions to various mob movements
  * camping capability
