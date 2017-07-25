package launcher;

import jade.core.Profile;
import jade.core.ProfileImpl;
import jade.core.Runtime;
import jade.wrapper.AgentController;
import jade.wrapper.ContainerController;
import jade.wrapper.ControllerException;
import jade.wrapper.StaleProxyException;

/**
 * Launches JADE agents and communication with Matlab and SIMULINK
 * @author kcchu
 */
public class Launcher
{

	static ContainerController cController;

	static String MATLAB_COM_NAME = "matlabAgentCom"; 
	static String MATLAB_COM_CLASS = "matlab.MatlabAgentCom";
	static String MATLAB_SIM_NAME = "simulink"; 
	static String MATLAB_SIM_CLASS = "matlab.MatlabAgentSimulink"; 
	static String MATLAB_MB1_NAME = "mb1"; 
	static String MATLAB_MB1_CLASS = "matlab.MatlabAgentMB1";
	static String MATLAB_MB2_NAME = "mb2"; 
	static String MATLAB_MB2_CLASS = "matlab.MatlabAgentMB2";
	static String MATLAB_SB1_NAME = "sb1"; 
	static String MATLAB_SB1_CLASS = "matlab.MatlabAgentSB1";
	static String MATLAB_SB2_NAME = "sb2"; 
	static String MATLAB_SB2_CLASS = "matlab.MatlabAgentSB2";
	static String MATLAB_OBJ_NAME = "obj"; 
	static String MATLAB_OBJ_CLASS = "matlab.MatlabAgentObj";
	 
	 

	/**
	 * Main function
	 * @param args
	 */
	public static void main(String[] args)
	{		
		try 
		{
			runJade();
		} 
		catch (StaleProxyException e) {} 
		catch (ControllerException e) {}	
	}


	/**
	 * Runs JADE and starts the initial agents
	 * @throws ControllerException
	 */
	public static void runJade() throws ControllerException
	{
		// Launch JADE platform
		Runtime rt = Runtime.instance();
		Profile p;
		p = new ProfileImpl();
		cController = rt.createMainContainer(p);			
		rt.setCloseVM(true);
	
		// Launch Matlab interface agent
		addAgent(MATLAB_COM_NAME, MATLAB_COM_CLASS, null);
		
		// Launch Matlab/SIMULINK agents
		addAgent(MATLAB_SIM_NAME, MATLAB_SIM_CLASS, null);
		addAgent(MATLAB_MB1_NAME, MATLAB_MB1_CLASS, null);
		addAgent(MATLAB_MB2_NAME, MATLAB_MB2_CLASS, null);
		addAgent(MATLAB_SB1_NAME, MATLAB_SB1_CLASS, null);
		addAgent(MATLAB_SB2_NAME, MATLAB_SB2_CLASS, null);
		addAgent(MATLAB_OBJ_NAME, MATLAB_OBJ_CLASS, null);

		addAgent("ac", "matlab.MatlabAgentLoadAC", null);
		addAgent("autopilot", "matlab.MatlabAgentLoadAutopilot", null);
		addAgent("lights", "matlab.MatlabAgentLoadLight", null);
		addAgent("usb", "matlab.MatlabAgentLoadUSB", null);
		addAgent("pv", "matlab.MatlabAgentPwPV", null);
		addAgent("charger", "matlab.MatlabAgentPwCharger", null);
	}


	/**
	 * Creates and starts an agent
	 * @param name
	 * @param type
	 * @throws ControllerException
	 */
	private static void addAgent(String name, String type, String arg) throws ControllerException 
	{		
		Object[] argsObj = {arg};
		AgentController ac = cController.createNewAgent(name, type, argsObj);
		ac.start();
	}


} // End class


