# jade2sim
Prepared by Kang-Ching (Jean) Chu on 2/14/2017

### Code structure

- In JADE:
  - Launcher.java: A  class that runs JADE agents.
  - MatlabAgentCom.java: An agent that acts as a server and forwards information between JADE and Matlab.
  - MatlabAgentSimulink.java: An agent that initiates simulation in simulink and deletes agents of all the ocntrolled devices at the end.
  - MatlabAgentMB1.java: An agent that controls device "MB1" in Simulink. (Same for MB2, SB1, SB2). 

- In Matlab:
  - main_sync.m: This is the main file, that establishes the TCP connection, handles messages, and runs Simulink.
  - BugE_v0_40_MAS.slx: Vehicle simulaiton model in Simulink.
  - The other files are just functions used by main.m, including all the files in the data folder.

### Using the code

The following software are required:

- Matlab/Simulink (tested with R2015b) with the Instrument Control Toolbox. This toolbox is only used for the TCP functions. 
- JADE (tested with 4.4.0) libraries. JADE lib folder includes the 4.4.0 library as jade.jar

Code use instructions are as follows:

1. Get the jade2sim files.
2. Import them to your favorite Java IDE, like Eclipse.
3. Get JADE jar libraries or use the one in JADE lib folder. 
4. Include the libraries to the jade2sim project.
5. Run the JADE program with the Launcher class.
7. In Matlab, open the main_sync.m file and run it.
8. The communication should then be established, followed by the simulation. You should see things displaying in the console and Matlab command window.
9. After the simulaiton in Simulink finished and results are plotted and displayed in Matlab, terminate JADE program.  


