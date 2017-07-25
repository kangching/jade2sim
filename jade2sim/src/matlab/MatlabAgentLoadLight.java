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
		// Local variables
		private String device = "LD_Lights";
		private double pReq, pMax, pOut, simTime, price, level;
		private double alpha = 2.0;
		double beta;
		private double levelMin = 0.5;
		double delta;
		private String output;



		@Override
		public void action() 
		{	

				MessageTemplate mt = MessageTemplate.MatchConversationId("get-bid");
				ACLMessage inputMsg = myAgent.receive(mt);
				if(inputMsg!=null)
				{
						
					String input = inputMsg.getContent();
	//				ACLMessage reply = inputMsg.createReply();
	//				System.out.println(getLocalName() + ": Input: " + input);
					
					delta = parseAnswerDouble(input)[0];
					pReq = parseAnswerDouble(input)[1];
					beta = parseAnswerDouble(input)[2];
					simTime = parseAnswerDouble(input)[3];
				
					
					double[] replyObj=new double[]{alpha, levelMin};
					
					sendMessage("obj",Arrays.toString(replyObj).replace("[", "").replace("]", ""),"bid",ACLMessage.INFORM);
					
//					System.out.println(getLocalName() + ": bid: " + Arrays.toString(replyObj).replace("[", "").replace("]", ""));
					MessageTemplate mtreply = MessageTemplate.MatchConversationId("price");

				ACLMessage reply = myAgent.receive(mtreply);
				if(reply!=null)
				{	
					String cost = reply.getContent();
	//				ACLMessage reply = inputMsg.createReply();
//					System.out.println(getLocalName() + ": Input: " + input);
					
					price = parseAnswerDouble(cost)[0];
					
					level = 1-Math.pow(1-Math.max(Math.min(beta*(1.5+delta-price), 1), 0),1/alpha)*(1-levelMin);
					
					pMax = pReq;
					
					pOut = pReq*level;
					
				
					

				output = device + ",Pmax,level,Pout,simtime," + Double.toString(pMax) + "," + Double.toString(level) + "," + Double.toString(pOut) + "," + Double.toString(simTime);

//					reply.setContent(output);
//					myAgent.send(reply);
				sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);

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
