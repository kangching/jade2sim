package matlab;

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
public class MatlabAgentSimulink extends Agent
{

	private static final long serialVersionUID = -4394243932169660776L;

	static final String LIST_DEVICES = "list-devices";
	static final String GET_PARAMETERS_SINGLE = "get-parameters-single";
	static final String GET_PARAMETERS_MULTIPLE = "get-parameters-multiple";
	static final String CHANGE_PARAMETERS_SINGLE = "change-parameters-single";
	static final String CHANGE_PARAMETERS_MULTIPLE = "change-parameters-multiple";
	static final String RUN_SIMULINK = "run-simulink";
	static final String SEND_OUTPUT = "send-output";
	static final String END_CONNECTION = "end-connection";
	static final String GET_OUTPUT = "get-output";

	static String MATLAB_COM_NAME = "matlabAgentCom"; 
	String matlabAgent = MATLAB_COM_NAME;
	

	
	
	
	// Setup method
	protected void setup() 
	{
		System.out.println(getName() + " successfully started");
		
		// Wait for a message from the server agent to start sending request
		MessageTemplate mt = MessageTemplate.MatchConversationId("start-now");
		blockingReceive(mt).getContent();
		System.out.println(getLocalName() + ": Starting communication...");
		
		// Run behavior
		SimulinkSimulation simulinkSimulation = new SimulinkSimulation();
		addBehaviour(simulinkSimulation);

	} // End setup


	/**
	 * Handles Simulink simulation request to Matlab
	 * @author kcchu
	 */
	class SimulinkSimulation extends SimpleBehaviour
	{

		private static final long serialVersionUID = 8966535884137111965L;


		@Override
		public void action() 
		{	

			// Local variables
			String answer = "";
			String outputMB1 = "";
//			String outputMB2 = "";

			
			
			/* SCRIPT COMMANDS */
			
//			System.out.println("*******************************");
//			System.out.println("TESTING RUNNING SIMULINK");
//			System.out.println("*******************************");
			
			/* Run Simulink */
			sendMessage(matlabAgent,"",RUN_SIMULINK,ACLMessage.INFORM);
			answer = blockingReceive().getContent();
			if(answer.equals("Simulating"))
			{
			MessageTemplate  msgAgent= MessageTemplate.MatchSender(new AID (matlabAgent, AID.ISLOCALNAME));
			ACLMessage answerAgent = receive(msgAgent);
				if(answerAgent!=null)
				{
					answer = answerAgent.getContent();
	//				System.out.println(getLocalName() + ": Messsage received from Matlab: " + answer);
					
					MessageTemplate  msgMB1= MessageTemplate.MatchSender(new AID ("mb1", AID.ISLOCALNAME));
					ACLMessage outputReply = receive(msgMB1);
					if(outputReply!=null)
					{
						outputMB1 = outputReply.getContent();
						System.out.println(getLocalName() + ": Get MB1 output = " + outputMB1);
						sendMessage(matlabAgent,outputMB1,SEND_OUTPUT,ACLMessage.INFORM);
					}
		//			sendMessage("mb1",answer,GET_OUTPUT,ACLMessage.INFORM);
		//			output2 = blockingReceive().getContent();
		
		//			System.out.println(getLocalName() + ": Messsage received from Matlab: " + answer);
					
					/* END CONNECTION */
					if(answer.equals("Done"))
					{
						System.out.println("*******************************");
						System.out.println("DONE WITH SIMULATION, CLOSING IT AND CLOSING THE CONNECTION");
						System.out.println("*******************************");
						
			
						// End connection
						sendMessage(matlabAgent,"",END_CONNECTION,ACLMessage.INFORM);
						sendMessage("mb1","",END_CONNECTION,ACLMessage.INFORM);
						
						// Kill agent
						myAgent.doDelete();
					}
				}
			}
			
			// End connection
			//sendMessage(matlabAgent,"",END_CONNECTION,ACLMessage.INFORM);
			MessageTemplate mtEnd = MessageTemplate.MatchConversationId(END_CONNECTION);
			ACLMessage endMsg = receive(mtEnd);
			if(endMsg!=null)
			{
				sendMessage("mb1","",END_CONNECTION,ACLMessage.INFORM);
				sendMessage("mb2","",END_CONNECTION,ACLMessage.INFORM);
				sendMessage("sb1","",END_CONNECTION,ACLMessage.INFORM);
				sendMessage("sb2","",END_CONNECTION,ACLMessage.INFORM);
				sendMessage("obj","",END_CONNECTION,ACLMessage.INFORM);
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
