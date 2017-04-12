package matlab;

import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.SimpleBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import jade.lang.acl.StringACLCodec;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;


/**
 * This class acts as a server that handles communication 
 * with Matlab and SIMULINK. 
 * @author kcchu
 */
public class MatlabAgentCom extends Agent
{

	private static final long serialVersionUID = -4394243932169660776L;

	static final String LIST_DEVICES = "list-devices";
	static final String GET_PARAMETERS_SINGLE = "get-parameters-single";
	static final String GET_PARAMETERS_MULTIPLE = "get-parameters-multiple";
	static final String CHANGE_PARAMETERS_SINGLE = "change-parameters-single";
	static final String CHANGE_PARAMETERS_MULTIPLE = "change-parameters-multiple";
	static final String RUN_SIMULINK = "run-simulink";
	static final String READ_INPUT = "read-input";
	static final String END_CONNECTION = "end-connection";


	// TCP connection variables
	ServerSocket srvr = null;
	Socket skt = null;
	BufferedReader in;
	PrintWriter out;
	String ip = "localhost";
	String filePath;
	int port = 1234;


	// Setup method
	protected void setup() 
	{
		System.out.println(getName() + " successfully started");

		// Get arguments
		Object[] args = getArguments();
		filePath = (String) args[0];

		// Create the TCP connection
		try 
		{
			// Create server and socket
			srvr = new ServerSocket(port);
			skt = srvr.accept();
			System.out.println(getLocalName() + ": Server connection initiated");

			// Create writer and reader to send and receive data
			out = new PrintWriter(skt.getOutputStream(), true);
			in = new BufferedReader(new InputStreamReader(skt.getInputStream()));
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
		}

		// Send a message to the tester to say its can start sending requests
		//sendMessage("Tester","","start-now",ACLMessage.INFORM);
		sendMessage("simulink","","start-now",ACLMessage.INFORM);
		sendMessage("obj","","start-now",ACLMessage.INFORM);
		sendMessage("mb1","","start-now",ACLMessage.INFORM);
		sendMessage("mb2","","start-now",ACLMessage.INFORM);
		sendMessage("sb1","","start-now",ACLMessage.INFORM);
		sendMessage("sb2","","start-now",ACLMessage.INFORM);
		sendMessage("ac","","start-now",ACLMessage.INFORM);
		sendMessage("autopilot","","start-now",ACLMessage.INFORM);
		sendMessage("lights","","start-now",ACLMessage.INFORM);
		sendMessage("usb","","start-now",ACLMessage.INFORM);

		// Run behavior
		CommWithMatlab commWithMatlab = new CommWithMatlab();
		addBehaviour(commWithMatlab);

	} // End setup


	/**
	 * A behaviour acting as an interface between JADE and Matlab
	 * Matlab itself has scripts acting as an interface between Matlab and PowerWorld
	 * @author Robin
	 */
	class CommWithMatlab extends SimpleBehaviour
	{

		private static final long serialVersionUID = 8966535884137111965L;


		@Override
		public void action() 
		{	

			// Wait for a message from another agent requesting something
			
			ACLMessage msg = blockingReceive();


			// If this is to list the devices of a given type
			if(msg.getConversationId().equals(LIST_DEVICES))
			{
				// Prepare message to send
				String type = msg.getContent();
				String simRequest = LIST_DEVICES + "," + type;

				// Send the message and retrieve the answer
				//System.out.println(getLocalName() + ": Message sent to Matlab: " + simRequest);
				String simAnswer = callMatlab(simRequest);
				out.flush();

				// Display error if any
				String[] cutAnswer = simAnswer.split(",");
				if(cutAnswer.length>1)
				{
					//System.out.println(getLocalName() + ": Message received from Matlab: " + simAnswer);
				}
				else
					System.err.println(getLocalName() + ": ListDevices failed: '" + cutAnswer[0] + "'");

				// Send the answer to the agent that request it
				sendMessage(msg.getSender().getLocalName(),simAnswer,LIST_DEVICES,ACLMessage.INFORM);
			}

			// If this is to get the parameters of a single element
			if(msg.getConversationId().equals(GET_PARAMETERS_SINGLE))
			{
				// Prepare message to send
				String simRequest = GET_PARAMETERS_SINGLE + "," + msg.getContent();

				// Send the message and retrieve the answer
				//System.out.println(getLocalName() + ": Message sent to Matlab: " + simRequest);
				String simAnswer = callMatlab(simRequest);
				out.flush();

				// Display error if any
				String[] cutAnswer = simAnswer.split(",");
				if(cutAnswer.length>1)
				{
					//System.out.println(getLocalName() + ": Message received from Matlab: " + simAnswer);
				}
				else
					System.err.println(getLocalName() + ": GetParametersSingle failed: '" + cutAnswer[0] + "'");

				// Send the answer to the agent that request it
				sendMessage(msg.getSender().getLocalName(),simAnswer,GET_PARAMETERS_SINGLE,ACLMessage.INFORM);
			}

			// If this is to get the parameters of multiple elements
			if(msg.getConversationId().equals(GET_PARAMETERS_MULTIPLE))
			{
				// Prepare message to send
				String simRequest = GET_PARAMETERS_MULTIPLE + "," + msg.getContent();

				// Send the message and retrieve the answer
				//System.out.println(getLocalName() + ": Message sent to Matlab: " + simRequest);
				String simAnswer = callMatlab(simRequest);
				out.flush();

				// Display error if any
				String[] cutAnswer = simAnswer.split(",");
				if(cutAnswer.length>1)
				{
					//System.out.println(getLocalName() + ": Message received from Matlab: " + simAnswer);
				}
				else
					System.err.println(getLocalName() + ": GetParametersMultiple failed: '" + cutAnswer[0] + "'");

				// Send the answer to the agent that request it
				sendMessage(msg.getSender().getLocalName(),simAnswer,GET_PARAMETERS_MULTIPLE,ACLMessage.INFORM);
			}

			// If this is to change the parameters of a single element
			if(msg.getConversationId().equals(CHANGE_PARAMETERS_SINGLE))
			{
				// Prepare message to send
				String simRequest = CHANGE_PARAMETERS_SINGLE + "," + msg.getContent();

				// Send the message and retrieve the answer
				//System.out.println(getLocalName() + ": Message sent to Matlab: " + simRequest);
				String simAnswer = callMatlab(simRequest);
				out.flush();

				if(!simAnswer.equals(""))
					System.err.println(getLocalName() + ": ChangeParametersSingle failed: '" + simAnswer + "'");
			}

			// If this is to change the parameters of multiple elements
			if(msg.getConversationId().equals(CHANGE_PARAMETERS_MULTIPLE))
			{
				// Prepare message to send
				String simRequest = CHANGE_PARAMETERS_MULTIPLE + "," + msg.getContent();

				// Send the message and retrieve the answer
				//System.out.println(getLocalName() + ": Message sent to Matlab: " + simRequest);
				String simAnswer = callMatlab(simRequest);
				out.flush();

				if(!simAnswer.equals(""))
					System.err.println(getLocalName() + ": ChangeParametersMultiple failed: '" + simAnswer + "'");
			}

			// If this is to run simulink
			if(msg.getConversationId().equals(RUN_SIMULINK))
			{
				// Prepare message to send
				String simRequest = RUN_SIMULINK;
				String inputAnswer = "";
				String outputMB1 = "";
				String outputMB2 = "";
				String outputSB1 = "";
				String outputSB2 = "";
				String outputAC = "";
				String outputAutopilot = "";
				String outputLights = "";
				String outputUSB = "";
				String outputObj = "";


				// Send the message and retrieve the answer
				System.out.println(getLocalName() + ": Message sent to Matlab: " + simRequest);
				String simAnswer = callMatlab(simRequest);
				out.flush();
				
				sendMessage(msg.getSender().getLocalName(),simAnswer,RUN_SIMULINK,ACLMessage.INFORM);

				while(simAnswer!="Done")
				{
					inputAnswer = callMatlab(READ_INPUT);
					out.flush();
					if(!inputAnswer.equals("Done"))
					{
	//					
						sendMessage("obj",inputAnswer,"get-output",ACLMessage.INFORM);
//						System.out.println(getLocalName() + ": Read input received from Matlab: " + inputAnswer);
//						sendMessage("mb1",inputAnswer,"get-output",ACLMessage.INFORM);
						MessageTemplate  msgMB1= MessageTemplate.MatchSender(new AID ("mb1", AID.ISLOCALNAME));
						ACLMessage outputReplyMB1 = receive(msgMB1);
						
//						sendMessage("mb2",inputAnswer,"get-output",ACLMessage.INFORM);
						MessageTemplate  msgMB2= MessageTemplate.MatchSender(new AID ("mb2", AID.ISLOCALNAME));
						ACLMessage outputReplyMB2 = receive(msgMB2);
						
//						sendMessage("sb1",inputAnswer,"get-output",ACLMessage.INFORM);
						MessageTemplate  msgSB1= MessageTemplate.MatchSender(new AID ("sb1", AID.ISLOCALNAME));
						ACLMessage outputReplySB1 = receive(msgSB1);
						
//						sendMessage("sb2",inputAnswer,"get-output",ACLMessage.INFORM);
						MessageTemplate  msgSB2= MessageTemplate.MatchSender(new AID ("sb2", AID.ISLOCALNAME));
						ACLMessage outputReplySB2 = receive(msgSB2);
						
						MessageTemplate  msgAC= MessageTemplate.MatchSender(new AID ("ac", AID.ISLOCALNAME));
						ACLMessage outputReplyAC = receive(msgAC);
						
						MessageTemplate  msgAutopilot= MessageTemplate.MatchSender(new AID ("autopilot", AID.ISLOCALNAME));
						ACLMessage outputReplyAutopilot = receive(msgAutopilot);
						
						MessageTemplate  msgLights= MessageTemplate.MatchSender(new AID ("lights", AID.ISLOCALNAME));
						ACLMessage outputReplyLights = receive(msgLights);
						
						MessageTemplate  msgUSB= MessageTemplate.MatchSender(new AID ("usb", AID.ISLOCALNAME));
						ACLMessage outputReplyUSB = receive(msgUSB);
						
						MessageTemplate  msgObj= MessageTemplate.MatchSender(new AID ("obj", AID.ISLOCALNAME));
						ACLMessage outputReplyObj = receive(msgObj);
						/* Send output together*/
						
						if(outputReplyMB1!=null && outputReplyMB2!=null && outputReplySB1!=null && outputReplySB2!=null && outputReplyAC!=null && outputReplyAutopilot!=null && outputReplyLights!=null && outputReplyUSB!=null && outputReplyObj!=null)
						{
							outputMB1 = outputReplyMB1.getContent();
							outputMB2 = outputReplyMB2.getContent();
							outputSB1 = outputReplySB1.getContent();
							outputSB2 = outputReplySB2.getContent();
							outputAC = outputReplyAC.getContent();
							outputAutopilot = outputReplyAutopilot.getContent();
							outputLights = outputReplyLights.getContent();
							outputUSB = outputReplyUSB.getContent();
							outputObj = outputReplyObj.getContent();
							String outputAnswer = callMatlab("send-output-all," + outputMB1 + "," + outputMB2 + "," + outputSB1 + ","  + outputSB2 + ","  + outputAC + ","  + outputAutopilot + ","  + outputLights + ","  + outputUSB + ","  + outputObj);
							outputMB1 = "";
							outputMB2 = "";
							outputSB1 = "";
							outputSB2 = "";
							outputAC = "";
							outputAutopilot = "";
							outputLights = "";
							outputUSB = "";
							outputObj = "";
							out.flush();
							
							if(outputAnswer.equals("Done"))
								sendMessage("simulink","",END_CONNECTION,ACLMessage.INFORM);
//								System.err.println(getLocalName() + ": send-output-all failed: '" + outputAnswer + "'");
						}
					}else{
						sendMessage("simulink","",END_CONNECTION,ACLMessage.INFORM);
					}
					
						
					/* Send output one by one*/
//					if(outputReplyMB1!=null)
//					{
//						outputMB1 = outputReplyMB1.getContent();
////						System.out.println(getLocalName() + ": Get MB1 output = " + outputMB1);
//						String outputAnswer = callMatlab("send-output," + outputMB1);
//						out.flush();
//					}
//					
//					if(outputReplyMB2!=null)
//					{
//						outputMB2 = outputReplyMB2.getContent();
////						System.out.println(getLocalName() + ": Get MB2 output = " + outputMB2);
//						String outputAnswer = callMatlab("send-output," + outputMB2);
//						out.flush();
//					}
//					
//					if(outputReplySB1!=null)
//					{
//						outputSB1 = outputReplySB1.getContent();
////						System.out.println(getLocalName() + ": Get SB1 output = " + outputSB1);
//						String outputAnswer = callMatlab("send-output," + outputSB1);
//						out.flush();
//					}
//					
//					if(outputReplySB2!=null)
//					{
//						outputSB2 = outputReplySB2.getContent();
////						System.out.println(getLocalName() + ": Get SB2 output = " + outputSB2);
//						String outputAnswer = callMatlab("send-output," + outputSB2);
//						out.flush();
//					}
	
				}
				

			}


			// If this is to end the connection with Matlab
			if(msg.getConversationId().equals(END_CONNECTION))
			{
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

		// Request Matlab to close the connection
		String msgContent = END_CONNECTION;

		String simAnswer = callMatlab(msgContent);

		if(!simAnswer.equals(""))
			System.out.println(getLocalName() + ": connection ending failed: '" + simAnswer + "'");

		// Close TCP writer and socket
		try 
		{
			out.close();
			in.close();
			skt.close();
			srvr.close();
		} 
		catch (IOException e) {	e.printStackTrace(); }
	}


	/**
	 * Sends a message to Matlab and returns an answer
	 * @param msgContent
	 * @return
	 */
	private String callMatlab(String msgContent) 
	{

		ACLMessage msg;
		String matlabAnswer = "";

		// Send the message to Matlab via JADE
		msg = new ACLMessage(ACLMessage.INFORM);
		msg.addReceiver(new AID(ip + ":1234", AID.ISGUID));
		msg.setContent(msgContent);

		// Encode message to send as an ACL Message
		StringACLCodec codec = new StringACLCodec(in, out);
		codec.write(msg);
		out.flush();

		// Wait for its answer
		try 
		{
			while (!in.ready()) {}
			matlabAnswer = matlabAnswer + in.readLine().toString();
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
		}

		return matlabAnswer;

	} // End callMatlab


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
