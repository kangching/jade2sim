package matlab;

import java.util.Arrays;

import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.SimpleBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;


/**
 * This agent sends requests to SIMULINK through the other agent
 * that adapts and forwards its requests to Matlab.
 * @author kcchu
 */
public class MatlabAgentObj extends Agent
{

	private static final long serialVersionUID = -4394243932169660776L;

	static final String GET_PARAMETERS_SINGLE = "get-parameters-single";
	static final String GET_PARAMETERS_MULTIPLE = "get-parameters-multiple";
	static final String CHANGE_PARAMETERS_SINGLE = "change-parameters-single";
	static final String CHANGE_PARAMETERS_MULTIPLE = "change-parameters-multiple";
	static final String END_CONNECTION = "end-connection";

	static String MATLAB_NAME = "matlabAgentCom"; 
	String matlabAgent = MATLAB_NAME;
	
	// Setup method
	protected void setup() 
	{
		System.out.println(getName() + " successfully started");

		
		// Wait for a message from the server agent to start sending request
		MessageTemplate mt = MessageTemplate.MatchConversationId("start-now");
		blockingReceive(mt).getContent();
		System.out.println(getLocalName() + ": Starting communication...");
		
		// Run behavior
		CommWithMatlab commWithMatlab = new CommWithMatlab();
		addBehaviour(commWithMatlab);

	} // End setup


	/**
	 * Handles communication between the other agents and Matlab
	 * @author kcchu
	 */
	class CommWithMatlab extends SimpleBehaviour
	{

		private static final long serialVersionUID = 8966535884137111965L;


		@Override
		public void action() 
		{	

			// Local variables
//			String params;
			double mb1, mb2, sb1, sb2, load, mb1Iout, mb2Iout, mb1SOC, mb2SOC, sb1SOC, sb2SOC;
			double vBus, iMotor, simTime;
			double mb1Vin, mb1SlopeAdj, mb1V0Adj, mb1Imin, mb1Imax;
			double mb2Vin, mb2SlopeAdj, mb2V0Adj, mb2Imin, mb2Imax;
			double sb1Vin, sb1SlopeAdj, sb1V0Adj, sb1Imin, sb1Imax;
			double sb2Vin, sb2SlopeAdj, sb2V0Adj, sb2Imin, sb2Imax;
			double IoutTotal, relativeSOC1, relativeSOC2;
			int balanceType;
			String input = "";
			String output = "";
					
			/* GET PARAMETERS */
				
//			System.out.println("*******************************");
//			System.out.println("TESTING IF GETTING PARAMETERS WORKS");
//			System.out.println("*******************************");
//			
//			// Get parameters of DCDC
//			params = "MC_Imax,MB1_DCDC_slope,MB1_DCDC_V0";
//			request = params;
//			sendMessage(matlabAgent,request,GET_PARAMETERS_MULTIPLE,ACLMessage.INFORM);
//			answer = blockingReceive().getContent();
//			System.out.println(getLocalName() + ": Get MB1 parameters answer = " + answer);
////			Object[][] ParamsData = parseAnswerString(answer);
////			printDataArray(ParamsData);
//			
//			mcImax = parseAnswerDouble(answer)[0];
//			slope = parseAnswerDouble(answer)[1];
//			v0 = parseAnswerDouble(answer)[2];
			
//			mcImax = 12.0;
//			slope = 50.0;
//			v0 = 24.0;
			
//			
//			/* CHANGE PARAMETERS */
//			
//			System.out.println("*******************************");
//			System.out.println("TESTING IF CHANGING PARAMETERS WORKS");
//			System.out.println("*******************************");
//			
//			// Change parameters for a bus (change name of bus 1)
//			type = "MB_DCDC";
//			nbFields = 2;
//			fields = "slope,V0";
//			values = (1+Integer.parseInt((String)dcdcsParamsData[0][0])) + "," + dcdcsParamsData[0][1];
//			request = type + "," + nbFields + "," + fields + "," + values;
//			sendMessage(matlabAgent,request,CHANGE_PARAMETERS_SINGLE,ACLMessage.INFORM);

			
			
			/* Finish parameters changes */
//			
//			System.out.println("*******************************");
//			System.out.println("TESTING TO RUN SIMULATION THROUGH ANOTHER AGENT");
//			System.out.println("*******************************");
//			
//			sendMessage("simulink","","start-now",ACLMessage.INFORM);
			
			MessageTemplate mt = MessageTemplate.MatchConversationId("get-output");
			ACLMessage inputMsg = receive(mt);
			if(inputMsg!=null)
			{
					
				input = inputMsg.getContent();
//				ACLMessage reply = inputMsg.createReply();
//				System.out.println(getLocalName() + ": Input: " + input);
				
				vBus = parseAnswerDouble(input)[0];
				iMotor = parseAnswerDouble(input)[1];
				mb1Vin = parseAnswerDouble(input)[2];
				mb1SlopeAdj = 0.0; //parseAnswerDouble(input)[6];
				mb1V0Adj = 0.0; //parseAnswerDouble(input)[8];
				mb1Imin = parseAnswerDouble(input)[10];
				mb1Imax = parseAnswerDouble(input)[12];
				
				mb2Vin = parseAnswerDouble(input)[3];
				mb2SlopeAdj = 0.0; //parseAnswerDouble(input)[7];
				mb2V0Adj = 0.0; //parseAnswerDouble(input)[9];
				mb2Imin = parseAnswerDouble(input)[11];
				mb2Imax = parseAnswerDouble(input)[13];
				
				sb1Vin = parseAnswerDouble(input)[4];
				sb1SlopeAdj = 0.0; //parseAnswerDouble(input)[14];
				sb1V0Adj = 0.0; //parseAnswerDouble(input)[16];
				sb1Imin = parseAnswerDouble(input)[18];
				sb1Imax = parseAnswerDouble(input)[20];
				
				sb2Vin = parseAnswerDouble(input)[5];
				sb2SlopeAdj = 0.0; //parseAnswerDouble(input)[15];
				sb2V0Adj = 0.0; //parseAnswerDouble(input)[17];
				sb2Imin = parseAnswerDouble(input)[19];
				sb2Imax = parseAnswerDouble(input)[21];

				mb1 = parseAnswerDouble(input)[22];
				mb2 = parseAnswerDouble(input)[23];
				sb1 = parseAnswerDouble(input)[24];
				sb2 = parseAnswerDouble(input)[25];
				load = parseAnswerDouble(input)[26];
				mb1Iout = parseAnswerDouble(input)[27];
				mb2Iout = parseAnswerDouble(input)[28];
				mb1SOC = parseAnswerDouble(input)[29];
				mb2SOC = parseAnswerDouble(input)[30];
				sb1SOC = parseAnswerDouble(input)[31];
				sb2SOC = parseAnswerDouble(input)[32];
				
				simTime = parseAnswerDouble(input)[33];
				
				// SOC Balance 
				if(mb1+mb2>=2)
				{
					IoutTotal = mb1Iout + mb2Iout;
					if(IoutTotal>=Math.pow(10.0, -3.0))
					{
						balanceType = 2;
						relativeSOC1 = mb1SOC/Math.max(Math.max(mb1SOC, mb2SOC), Math.ulp(1.0));
						relativeSOC2 = mb2SOC/Math.max(Math.max(mb1SOC, mb2SOC), Math.ulp(1.0));
					}else if(IoutTotal<=Math.pow(-10.0, -3.0))
					{
						balanceType = 3;
						relativeSOC1 = 1/Math.max(Math.min(mb1SOC/Math.max(Math.max(mb1SOC, mb2SOC), Math.ulp(1.0)), 1.0), Math.ulp(1.0));
						relativeSOC2 = 1/Math.max(Math.min(mb2SOC/Math.max(Math.max(mb1SOC, mb2SOC), Math.ulp(1.0)), 1.0), Math.ulp(1.0));
					}else
					{
						balanceType = 1;
						relativeSOC1 = 1.0;
						relativeSOC2 = 1.0;
					}
					
					mb1SlopeAdj = Math.max(Math.min(Math.pow(relativeSOC1/Math.max(Math.min(Math.max(0.0,relativeSOC1), Math.max(0.0, relativeSOC2)),Math.ulp(1.0)),3.0),10.0),1);
					mb2SlopeAdj = Math.max(Math.min(Math.pow(relativeSOC2/Math.max(Math.min(Math.max(0.0,relativeSOC1), Math.max(0.0, relativeSOC2)),Math.ulp(1.0)),3.0),10.0),1);
							
				}
				
				// Prioritize SB
				
				sb1SlopeAdj = sb1+1.0;
				sb2SlopeAdj = sb2+1.0;
				
				// Driving performance
				
				double[] outputMB1=new double[]{vBus, iMotor, mb1Vin, mb1SlopeAdj, mb1V0Adj, mb1Imin, mb1Imax, mb1SOC, simTime};
				double[] outputMB2=new double[]{vBus, iMotor, mb2Vin, mb2SlopeAdj, mb2V0Adj, mb2Imin, mb2Imax, mb2SOC, simTime};
				double[] outputSB1=new double[]{vBus, iMotor, sb1Vin, sb1SlopeAdj, sb1V0Adj, sb1Imin, sb1Imax, sb1SOC, simTime};
				double[] outputSB2=new double[]{vBus, iMotor, sb2Vin, sb2SlopeAdj, sb2V0Adj, sb2Imin, sb2Imax, sb2SOC, simTime};
				
				sendMessage("mb1",Arrays.toString(outputMB1).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				sendMessage("mb2",Arrays.toString(outputMB2).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				sendMessage("sb1",Arrays.toString(outputSB1).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				sendMessage("sb2",Arrays.toString(outputSB2).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				
//				System.out.println(getLocalName() + ": Output to Matlab: " + output);
			}
			
			// End connection
			//sendMessage(matlabAgent,"",END_CONNECTION,ACLMessage.INFORM);
			MessageTemplate mtEnd = MessageTemplate.MatchConversationId(END_CONNECTION);
			ACLMessage endMsg = receive(mtEnd);
			if(endMsg!=null)
			{
			// Kill agent
				myAgent.doDelete();
			}
			
		} // End action


		@Override
		public boolean done() 
		{
			return false;	
		}

	} // End behavior


	@Override
	protected void takeDown()
	{
		System.out.println(getLocalName() + "Agent being taken down");
	}


	/**
	 * Parse an answer string received from Matlab
	 * Return a 2D array containing the data 
	 * @param answer
	 * @param types
	 * @return
	 */
	
	private double[] parseAnswerDouble(String answer)
	{
		// Split the incoming string
		String[] splitAnswer = answer.split(",");
		double[] data = new double[splitAnswer.length];
		for (int i = 0; i < data.length; i++) {
		    data[i] = Double.parseDouble(splitAnswer[i]);
		}
		return data;
	}
	
//	private Object[][] parseAnswerString(String answer)
//	{
//		// Split the incoming string
//		String[] splitAnswer = answer.split(",");
//		int nbElements = Integer.parseInt(splitAnswer[0]);
//		int nbParams = Integer.parseInt(splitAnswer[1]);
//
//		// Create the output data array
//		Object[][] data = new Object[nbElements][nbParams];
//
//		for(int i=0;i<nbElements;i++)
//		{
//			for(int j=0;j<nbParams;j++)
//			{
//				data[i][j] = splitAnswer[2+i*nbParams+j];
//			}
//		}
//
//		return data;
//	}


	/**
	 * Prints an array of values
	 * @param array
	 */
//	private void printDataArray(Object[][] array)
//	{
//		for(int i=0;i<array.length;i++)
//		{
//			for(int j=0;j<array[0].length;j++)
//			{
//				if(array[i][j].equals(" "))
//					System.out.print(Double.NaN + "\t");
//				else
//					System.out.print(array[i][j] + "\t");
//			}
//			System.out.println();
//		}
//	}


	/**
	 * Sends a message to another agent
	 * @param targetName
	 * @param content
	 * @param conversation
	 * @param type
	 */
	public void sendMessage(String targetName, String content, String conversation, int type)
	{
		ACLMessage message = new ACLMessage(type);
		message.addReceiver(new AID (targetName, AID.ISLOCALNAME));
		message.setContent(content);
		message.setConversationId(conversation);
		this.send(message);
	}

}
