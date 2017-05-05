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
public class MatlabAgentLoadAC extends Agent
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
		private String device = "LD_AC";
		private double pReq, pMax, pOut, simTime, price, level, vBus;
		private double alpha = 3.0;
		private double beta;
		private double levelMin = 0;
		private double delta;
		private String output;
		double busPmaxAbs = 240.0;
		double vBusMax = 25.0;
		double vBusMin = 17.0;
		double bus_beta = 0.9;

		public void action() 
		{	
			MessageTemplate mt = MessageTemplate.MatchConversationId("get-bid");
				ACLMessage inputMsg = myAgent.receive(mt);
				if(inputMsg!=null)
				{
						
					String input = inputMsg.getContent();
	//				ACLMessage reply = inputMsg.createReply();
	//				System.out.println(getLocalName() + ": Input: " + input);
					vBus = parseAnswerDouble(input)[0];
					pReq = parseAnswerDouble(input)[1];
					price = parseAnswerDouble(input)[2];
					simTime = parseAnswerDouble(input)[3];
					delta = parseAnswerDouble(input)[4];
					beta = parseAnswerDouble(input)[5];

					
					double[] replyObj=new double[]{alpha, levelMin};
					
					sendMessage("obj",Arrays.toString(replyObj).replace("[", "").replace("]", ""),"bid",ACLMessage.INFORM);
					MessageTemplate mtreply = MessageTemplate.MatchConversationId("price");

				ACLMessage reply = myAgent.receive(mtreply);
				if(reply!=null)
				{	
					String cost = reply.getContent();
	//				ACLMessage reply = inputMsg.createReply();
	//				System.out.println(getLocalName() + ": Input: " + input);
					
					price = parseAnswerDouble(cost)[0];
					
					level = 1-Math.pow(1-Math.max(Math.min(beta*(1+delta-price), 1), 0),1/alpha)*(1-levelMin);
					
					pMax = Math.min((Math.pow((1-bus_beta),2)/saturation((vBus-vBusMin)/(vBusMax-vBusMin), 1.0, Math.ulp(1.0)) - Math.pow((1-bus_beta),2) - 1)*busPmaxAbs,0);
					
					pOut = saturation(pReq*level, -pMax, 0.0);
					
				
					

				output = device + ",Pmax,level,Pout,simtime," + Double.toString(pMax) + "," + Double.toString(level) + "," + Double.toString(pOut) + "," + Double.toString(simTime);

//					reply.setContent(output);
//					myAgent.send(reply);
				sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);
//				System.out.println(getLocalName() + ": Output: " + output);
				
				}
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
	
	private double saturation(double input, double upperLimit, double lowerLimit)
	{
		double output;
		output = Math.min(Math.max(input, lowerLimit), upperLimit);
		return output;
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
