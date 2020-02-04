# arma3_cbrn
A simple CBRN system for Arma 3 missions. Requires ACE3 Medical.

## Usage
To use this script, place the "CBRN" folder in your mission directory, and add the following line to your CfgFunctions class in description.ext:
```sqf
#include "cbrn\config\CfgFunctions.hpp"
```

Once you have added the CBRN script to your mission, you will need to define your "hazard" zones. You will need to use triggers that meet the following criteria:
1. The trigger must be circular, not square.
1. The trigger must have *identical* X and Y dimensions.
1. The trigger must have no Z limit.
1. The trigger must **not** be set to "Server Only"
1. The trigger must be set to "Repeatable"

To activate the triggers with the CBRN script, you will need to set the "Condition" field to:
```sqf
this && player in thisList
```
The "On Activation" field will need to call the `SXP_CBRN_fnc_enterZone` function. Like so:
```sqf
[thisTrigger,player,1,50] call SXP_CBRN_fnc_enterZone
```
You can adjust the arguments of `SXP_CBRN_fnc_enterZone` to suit your needs for that specific zone. The accepted arguments are as follows:
```sqf
[trigger,player,intensity,falloffRange] call SXP_CBRN_fnc_enterZone
```
* Trigger - **Must** be set to `thisTrigger`. Allows the script to reference the trigger in question.
* Player - **Must** be set to `player`. Allows the script to reference the player unit directly.
* Intensity - Decimal number from 0 to 1. This is the maximum hazard value that can be found at the centre of the zone.
* Falloff Range (Optional) - Number between 0, and the size of the trigger. When specified, a maximum intensity zone will be created within this distance of the centre of the trigger. Defaults to 0 when undefined.

## Falloff range explained
The falloff range is a feature that allows for a CBRN/hazard zone to have a "maximum intensity" area at the centre of the zone. 

When no falloff range is defined, the "hazard value" of the zone scales linearly from the edge of the zone to the centre.

When a falloff range is defined, the hazard value stays constant until you reach that distance from the centre of the zone. After that point, the hazard scales linearly from the falloff distance to the edge of the zone.

## CBRN Protection
This script accounts for the usage of CBRN equipment to mitigate the effects of the CBRN zones, though it is configured to ensure that CBRN zones can still be a hazard, regardless of the equipment you have. CBRN protection uses two values; a flat protection value reduces the incoming hazard by a fixed amount, and a percentage resistance value reduces the remaining hazard by a percentage value. The CBRN gear will provide the following levels of protection (values are out of 100):

| Equipment | Protection | Resistance |
|---|:---:|:---:|
| Filtered gas mask (NATO/CSAT APRs) | 10 | 20% |
| Unfiltered gas mask (APR without filter, civilian regulator) | 10 | 0% |
| Unfiltered mask with **attached** air tank (SCBA/Combination Respirator)<sup>1</sup> | 30 | 50% |
| Filtered gas mask with CSAT fatigues<sup>2</sup> | 30 | 50% |
| CBRN suit, or CSAT fatigues<sup>2</sup> | 20 | 10% |
| Laws of War DLC medical face mask | 0 | 10% |

<sup>1</sup>The script checks if the optional "air hose textures" are applied on the backpack to provide the full resistance. Use of an optional mod to allow the connection of the air hose is recommended.

<sup>2</sup>CSAT combat fatigues are canonically CBRN protected, as they feature self-contained oxygen systems.

The maximum total protection that can be achieved (using a mask attached to an air tank, and a CBRN suit) is 50/60%. This makes the player entirely immune to hazard zones up to an intensity of 0.5, and provides a 60% resistance to anything above that. This works out to an effective resistance of 80% in an intensity 1 hazard zone.

## CBRN Damage
In order to provide a good "damage" system for the CBRN zones, while still integrating with other gameplay elements, the CBRN script relies on the ACE3 medical system to process damage. Specifically, the blood handling.

The CBRN script will deal damage by directly removing the blood of the affected unit, until they eventually lose consciousness, and die. This can of course be counteracted using blood bags to restore blood to the player.

Players start with 6 litres of blood in their system, and will be guaranteed to lose consciousness at 3.6 litres. The CBRN script (by default) will take an *unprotected* unit from full blood, to guaranteed unconsciousness in **five minutes** in an intensity 1 hazard zone.

You can adjust the amount of damage dealt (expressed in blood loss per minute) by adding the following line to your description.ext file:
```sqf
SXP_CBRN_damagePerMinute = 0.48;
```
The number is the amount of blood lost per minute at a hazard of 1, with no CBRN protection. The default value is `0.48`.
