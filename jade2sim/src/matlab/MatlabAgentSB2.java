package matlab;

import java.util.Arrays;

// import java.io.IOException;

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
public class MatlabAgentSB2 extends Agent
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
		// Local variables
		private String device = "SB2";
		private double vBus, vIn, slopeAdj, v0Adj, iMin, iMax, pOut, simTime, soc, price, priceZero;
		private double mcImax = 12.0;
		private double slope = 50.0;
		double v0 = 24.0;
		double pMax, pMin, pOutInitial;
		private String output;

		@Override
		public void action() 
		{	

//			// Local variables
//			String device = "SB1";
//			String params;
//			double vBus, iMotor, vIn, slopeAdj, v0Adj, iMin, iMax, pOut, simTime, soc;
//			double mcImax = 12.0;
//			double slope = 50.0;
//			double v0 = 24.0;
//			double pMax, pMin, pOutInitial;
//			String answer = "";
//			String request = "";
//			String input = "";
//			String output = "";
//					
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
			
			MessageTemplate mt = MessageTemplate.MatchConversationId("get-bid");
			ACLMessage inputMsg = receive(mt);
			if(inputMsg!=null)
			{
					
				String input = inputMsg.getContent();
//				ACLMessage reply = inputMsg.createReply();
//				System.out.println(getLocalName() + ": Input: " + input);
				
				vBus = parseAnswerDouble(input)[0];
//				iMotor = parseAnswerDouble(input)[1];
				vIn = parseAnswerDouble(input)[2];
				slopeAdj = parseAnswerDouble(input)[3];
				v0Adj = parseAnswerDouble(input)[4];
				iMin = parseAnswerDouble(input)[5];
				iMax = parseAnswerDouble(input)[6];
				soc = parseAnswerDouble(input)[7];
				simTime = parseAnswerDouble(input)[8];
				
	//			System.out.println(getLocalName() + ": " + vBus);
				
				pMin = -Math.min(iMax, mcImax)*Math.min(vIn, vBus);
//				pOutInitial = (-(vBus-(v0Adj+v0)))*(slopeAdj*slope);
				pMax = -Math.max(iMin, -mcImax)*Math.min(vIn, vBus);
				
//				if(pOutInitial>=pMax)
//					{
//					pOut = pMax;
//					}else if(pOutInitial<=pMin)
//					{
//						pOut = pMin;
//					}else
//					{
//						pOut = pOutInitial;
//					}
//				output = device + ",Pmax,Pmin,Pout,simtime," + Double.toString(pMax) + "," + Double.toString(pMin) + "," + Double.toString(pOut) + "," + simTime;

				double[] replyObj=new double[]{pMin, pMax};
				
				sendMessage("obj",Arrays.toString(replyObj).replace("[", "").replace("]", ""),"bid",ACLMessage.INFORM);
				MessageTemplate mtreply = MessageTemplate.MatchConversationId("price");
				
				ACLMessage reply = myAgent.receive(mtreply);
				if(reply!=null)
				{	
					String cost = reply.getContent();
	//				ACLMessage reply = inputMsg.createReply();
	//				System.out.println(getLocalName() + ": Input: " + input);
					
					price = parseAnswerDouble(cost)[0];
					priceZero = 1 - soc;
					pOut =saturation(pMax-2*(price-priceZero)*(v0Adj+v0)*(slopeAdj*slope), pMax, pMin);
					
					
					output = device + ",Pmax,Pmin,Pout,simtime," + Double.toString(-pMin) + "," + Double.toString(-pMax) + "," + Double.toString(-pOut) + "," + simTime;
					
					sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);

//				sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);
//				if(pOut >= pMax){
//					sendMessage("obj",Double.toString(pMax),"limit",ACLMessage.INFORM);
//				}else{
//					sendMessage("obj",Double.toString(pOut),"good",ACLMessage.INFORM);
//				}
				}


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
	
	private double saturation(double input, double upperLimit, double lowerLimit)
	{
		double output;
		output = Math.min(Math.max(input, lowerLimit), upperLimit);
		return output;
	}
/*	
	private Object[][] parseAnswerString(String answer)
	{
		// Split the incoming string
		String[] splitAnswer = answer.split(",");
		int nbElements = Integer.parseInt(splitAnswer[0]);
		int nbParams = Integer.parseInt(splitAnswer[1]);

		// Create the output data array
		Object[][] data = new Object[nbElements][nbParams];

		for(int i=0;i<nbElements;i++)
		{
			for(int j=0;j<nbParams;j++)
			{
				data[i][j] = splitAnswer[2+i*nbParams+j];
			}
		}

		return data;
	}
*/

	/**
	 * Prints an array of values
	 * @param array
	 */
/*	
	private void printDataArray(Object[][] array)
	{
		for(int i=0;i<array.length;i++)
		{
			for(int j=0;j<array[0].length;j++)
			{
				if(array[i][j].equals(" "))
					System.out.print(Double.NaN + "\t");
				else
					System.out.print(array[i][j] + "\t");
			}
			System.out.println();
		}
	}
*/

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
