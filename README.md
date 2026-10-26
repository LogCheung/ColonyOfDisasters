# Colony of Disasters
 Pirate Software 16 Game Jam Project Jan 2025 <br/>
 A colony simulation game where you play as a god that influences your colony
 through weather events. <br/> <br/>
 This project is completed. Link to GDD: https://docs.google.com/document/d/1FE9_PFNj-imvMxX42kc_Y4333oPJ04CWbmehIYfxWiU/edit?usp=sharing

 # Description
 Manage your colony's resources through weather events that can encourage buildings, 
 fend off raiders, or unearth resources. Ensure that your citizens continue to have
 faith in your power and guide your colony through challenging times such as when 
 raiders appear or the frigid cold of winter threatens their wellbeing. <br/> <br/>

 This project was made 8 months into my game development journey, I consider this project a
 turning point, no longer relied on tutorials, was able to problem solve on my own and spent nearly a 100 hours 
 ensuring I got to submit it. Fun two weeks.

 # Feature List
 - NPC Behaviors/States
   - Building (Pathfinding to site, giving up current task)
   - Farming (Pathfinding to farm tiles, planting/harvesting based on growth stage)
   - Forging (Pathfinding to smelter, then back to forge to produce tools)
   - Praying (Pathfinding to shrine, giving up current task, praying when work day ends)
   - Sleeping (Return to home until work day starts)
   - Idle (Wandering if no job, mostly for children)
   - War (Become soldier when raiders appear on the map)
 - Weather Events
   - Rain (Flood risk, farm tiles, improved growth, slowing raiders)
   - Wind (Seeds for trees and crops, housing encouragement, freezing risk, damage to raiders)
   - Earthquake (Iron ore spawning, forge encouragement, colony destruction risk, damage to raiders)
   - Declare Holy Land ( Place to encourage buildings with weather)
 - Day/Night Cycle
   - Work/Pray/Rest Schedule
 - Population Growth
   - Option to give birth in house, makes one worker pregnant)
   - Child growing into adults
 - Buildings
   - Houses (takes in citizens, consumes fuel)
   - Forge (takes worker, consumes iron and wood)
 - Challenges
   - Winter (increased consumptions, freeze risk)
   - Raiders/Combat
     - Citizens form up, approach enemy,
     - Armies clash, strength based on numbers, rolls made to decide victor
   - Tool consumption overtime, no tools = no work
   - Food/Fuel consumption
 - Event Log
   - Log deaths of citizens
   - Log risk of raiders
   - Log short guide/tutorial
   - Log response to weather events
   - Log alerts for resource scarcities
 - UI
   - Descriptions for each power button
   - Resource counters
 - Music
 - SFX

 # Design Reflection
 - Goal: To create an interesting simulation game through weather rather than directly controlling colony
 - Thoughts: Making a colony sim by only controlling weather is an interesting concept, though we gave the player too little agency, a small amount of decisions were to be made. Instead it was more watching a colony sim than playing. I am incredibly proud of this project, for nothing more than it gave me faith I could make what I what set out to do. From a design perspective, we limited player agency too much, and a much more engaging game would've resembled a more traditional colony sim with interesting weather mechanics to optimize play or accidentally ruin your colony with disasters (maybe with a chance that a weather event becomes a catastrophe and is much stronger than you intended). <br/>

 # Contributors
 - Programming : Logan Cheung (SpiralKing)
 - Art : Micah Rodriguez (Palatabled)
