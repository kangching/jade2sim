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
public class MatlabAgentLoadLight extends Agent
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
		addBehaviour(new PowerOutput());

	} // End setup


	/**
	 * Handles communication between the other agents and Matlab
	 * @author kcchu
	 */
	class PowerOutput extends SimpleBehaviour
	{

		private static final long serialVersionUID = 8966535884137111965L;


		@Override
		public void action() 
		{	

			// Local variables
			String device = "LD_Lights";
			double pReq, pMax, pOut, vBus, simTime, price, performance;
			double perfCoe = 2.0;
			int levelMin = 2;
			int level = levelMin;
			double costCoe = 2.0;
			double perfImprove = 0.0;
			double powerImprove = 0.0;
//			double busPmaxAbs = 250.0;
//			double vBusMax = 25.0;
//			double vBusMin = 17.0;
//			double beta = 0.9;
//			String answer = "";
//			String request = "";
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
				pReq = parseAnswerDouble(input)[1];
				price = parseAnswerDouble(input)[2];
				simTime = parseAnswerDouble(input)[3];
				
	//			System.out.println(getLocalName() + ": " + vBus);
				
//				pMax = Math.min((Math.pow((1-beta),2)/saturation((vBus-vBusMin)/(vBusMax-vBusMin), 1.0, Math.ulp(1.0)) - Math.pow((1-beta),2) - 1)*busPmaxAbs,0);
				
				pMax = pReq*level;
//				if(pReq >= -pMax)
//				{
//					sendMessage("obj",Double.toString(pReq+pMax),"power_request",ACLMessage.INFORM);
//					MessageTemplate msg = MessageTemplate.MatchConversationId("power_request");
//					ACLMessage reply = myAgent.receive(msg);
//					if (msg != null){
//						busPmaxAbs = Double.parseDouble(reply.getContent());
//						pMax = Math.min((Math.pow((1-beta),2)/saturation((vBus-vBusMin)/(vBusMax-vBusMin), 1.0, Math.ulp(1.0)) - Math.pow((1-beta),2) - 1)*busPmaxAbs,0);
//					}
//					else{
//						block();
//					}
//				}
				
				if(price<1.0){
					for(int i = 1; i<(5-levelMin); i++){
						double cost = (1/costCoe)*Math.exp(-(5-i)*0.25)/((5-i)*0.25);
								if(cost>=price){
									level = 5-i;
									break;
								}
					}
				}
				
				pOut = pReq*level*0.25;
				
				performance = 1-Math.pow((1-pOut/pReq)/(1-levelMin*0.25),perfCoe);
				
//				if(performance<1){
//					int levelImprove = level+1;
//					perfImprove = 1-Math.pow((1-levelImprove)/(1-levelMin*0.25),perfCoe)-performance;
//					powerImprove = saturation(pReq*levelImprove*0.25, -pMax, 0.0)-pOut;
//				
//					double[] outputImprove=new double[]{pOut, level, perfImprove, powerImprove};
//					sendMessage("obj",Arrays.toString(outputImprove).replace("[", "").replace("]", ""),"improve",ACLMessage.INFORM);
//					
//					MessageTemplate  reply= MessageTemplate.MatchConversationId("improve");
//					ACLMessage replyImprove = receive(reply);
//					if(replyImprove!=null){
//							level = level+Integer.parseInt(replyImprove.getContent());
//							pOut = saturation(pReq*level*0.25, -pMax, 0.0);
//							output = device + ",Pmax,level,Pout,simtime," + Double.toString(pMax) + "," + Double.toString(level) + "," + Double.toString(pOut) + "," + Double.toString(simTime);
//							sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);
//							
//					}
//				}else{
					output = device + ",Pmax,level,Pout,simtime," + Double.toString(pMax) + "," + Double.toString(level) + "," + Double.toString(pOut) + "," + Double.toString(simTime);

//					reply.setContent(output);
//					myAgent.send(reply);
					sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);
					
//				}
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
		String[] splitAnswer = answer.split(", ");
		double[] data = new double[splitAnswer.length];
		for (int i = 0; i < data.length; i++) {
		    data[i] = Double.parseDouble(splitAnswer[i]);
		}
		return data;
	}
	
//	private double saturation(double input, double upperLimit, double lowerLimit)
//	{
//		double output;
//		output = Math.min(Math.max(input, lowerLimit), upperLimit);
//		return output;
//	}
	
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
