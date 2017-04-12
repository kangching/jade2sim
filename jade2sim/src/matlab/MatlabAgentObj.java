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
			double acPreq, autopilotPreq, lightsPreq, usbPreq, price;
			double acLevel = 1.0;
			double autopilotLevel = 1.0;
			double lightsLevel = 1.0;
			double usbLevel = 1.0;
			double pMB1 = 0.0;
			double pMB2 = 0.0;
			double pSB1 = 0.0;
			double pSB2 = 0.0;
			double powerBattAll = 0.0;
			double vBusMin = 17.0;
			double vBusMax = 25.0;
			double IoutTotal, relativeSOC1, relativeSOC2;
			int balanceType;
			int limitMB1 = 0;
			int limitMB2 = 0;
			int limitSB1 = 0;
			int limitSB2 = 0;
			String input = "";
			String output = "";
			String device = "Obj";
					
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
				
				vBus = parseAnswerDouble(input)[1];
				iMotor = parseAnswerDouble(input)[2];
				mb1Vin = parseAnswerDouble(input)[3];
				mb1SlopeAdj = 1.0; //parseAnswerDouble(input)[6];
				mb1V0Adj = 0.0; //parseAnswerDouble(input)[8];
				mb1Imin = parseAnswerDouble(input)[11];
				mb1Imax = parseAnswerDouble(input)[13];
				
				mb2Vin = parseAnswerDouble(input)[4];
				mb2SlopeAdj = 1.0; //parseAnswerDouble(input)[7];
				mb2V0Adj = 0.0; //parseAnswerDouble(input)[9];
				mb2Imin = parseAnswerDouble(input)[12];
				mb2Imax = parseAnswerDouble(input)[14];
				
				sb1Vin = parseAnswerDouble(input)[5];
				sb1SlopeAdj = 1.0; //parseAnswerDouble(input)[14];
				sb1V0Adj = 0.0; //parseAnswerDouble(input)[16];
				sb1Imin = parseAnswerDouble(input)[19];
				sb1Imax = parseAnswerDouble(input)[21];
				
				sb2Vin = parseAnswerDouble(input)[6];
				sb2SlopeAdj = 1.0; //parseAnswerDouble(input)[15];
				sb2V0Adj = 0.0; //parseAnswerDouble(input)[17];
				sb2Imin = parseAnswerDouble(input)[20];
				sb2Imax = parseAnswerDouble(input)[22];

				mb1 = parseAnswerDouble(input)[23];
				mb2 = parseAnswerDouble(input)[24];
				sb1 = parseAnswerDouble(input)[25];
				sb2 = parseAnswerDouble(input)[26];
				mb1Iout = parseAnswerDouble(input)[27];
				mb2Iout = parseAnswerDouble(input)[28];
				mb1SOC = parseAnswerDouble(input)[29];
				mb2SOC = parseAnswerDouble(input)[30];
				sb1SOC = parseAnswerDouble(input)[31];
				sb2SOC = parseAnswerDouble(input)[32];
				
				acPreq = parseAnswerDouble(input)[33];
				autopilotPreq = parseAnswerDouble(input)[34];
				lightsPreq = parseAnswerDouble(input)[35];
				usbPreq = parseAnswerDouble(input)[36];
				
				simTime = parseAnswerDouble(input)[0];
				
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
				
				//
				mb1SlopeAdj = mb1SlopeAdj + saturation(10*Math.exp(-(vBus-vBusMin)),10,0)/50;
				mb2SlopeAdj = mb2SlopeAdj + saturation(10*Math.exp(-(vBus-vBusMin)),10,0)/50;
				sb1SlopeAdj = sb1SlopeAdj + saturation(10*Math.exp(-(vBus-vBusMin)),10,0)/50;
				sb2SlopeAdj = sb2SlopeAdj + saturation(10*Math.exp(-(vBus-vBusMin)),10,0)/50;
				
//				System.out.println(getLocalName() + ": slopeAdj: " + mb1SlopeAdj);
				
				// Load
				
				double[] outputMB1=new double[]{vBus, iMotor, mb1Vin, mb1SlopeAdj, mb1V0Adj, mb1Imin, mb1Imax, mb1SOC, simTime};
				double[] outputMB2=new double[]{vBus, iMotor, mb2Vin, mb2SlopeAdj, mb2V0Adj, mb2Imin, mb2Imax, mb2SOC, simTime};
				double[] outputSB1=new double[]{vBus, iMotor, sb1Vin, sb1SlopeAdj, sb1V0Adj, sb1Imin, sb1Imax, sb1SOC, simTime};
				double[] outputSB2=new double[]{vBus, iMotor, sb2Vin, sb2SlopeAdj, sb2V0Adj, sb2Imin, sb2Imax, sb2SOC, simTime};
				
				sendMessage("mb1",Arrays.toString(outputMB1).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
						
				MessageTemplate  msgMB1= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("mb1", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("limit"));
				ACLMessage replyMB1 = receive(msgMB1);
				if(replyMB1!=null){
					if(mb1 > 0){
						limitMB1 = 1;
						pMB1 = Double.parseDouble(replyMB1.getContent());
					}else{
						limitMB1 = 0;
					}
				}

				
				sendMessage("mb2",Arrays.toString(outputMB2).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				
				MessageTemplate  msgMB2= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("mb2", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("limit"));
				ACLMessage replyMB2 = receive(msgMB2);
				if(replyMB2!=null){
					if(mb2 > 0){
						limitMB2 = 1;
						pMB2 = Double.parseDouble(replyMB2.getContent());
					}else{
						limitMB2 = 0;
					}
				}

				
				sendMessage("sb1",Arrays.toString(outputSB1).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				
				MessageTemplate  msgSB1= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("sb1", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("limit"));
				ACLMessage replySB1 = receive(msgSB1);
				if(replySB1!=null){
					if(sb1 > 0){
						limitSB1 = 1;
						pSB1 = Double.parseDouble(replySB1.getContent());
					}else{
						limitSB1 = 0;
					}
				}

				sendMessage("sb2",Arrays.toString(outputSB2).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				
				MessageTemplate  msgSB2= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("sb2", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("limit"));
				ACLMessage replySB2 = receive(msgSB2);
				if(replySB2!=null){
					if(sb2 > 0){
						limitSB2 = 1;
						pSB2 = Double.parseDouble(replySB2.getContent());
					}else{
						limitSB2 = 0;
					}
				}

				if(limitMB1+limitMB2 >= 1){
					powerBattAll = pMB1+pMB2+pSB1+pSB2;
					double powerReqAll = acPreq+lightsPreq+usbPreq;
					double powerRatio = (powerBattAll-autopilotPreq)/powerReqAll;
	//				double loadLevel = usbLevel+acLevel+lightsLevel;
					
					if(powerRatio <=0){
						price = 1;
					}else{
						price = 1-Math.max(0, (powerRatio-0.2)/0.8);
					}
				}else{
					price = 0;
				}
//				System.out.println(getLocalName() + ": Price: " + powerRatio + "," + powerBattAll + "," + autopilotPreq);
				
				
//				if(limitMB1+limitMB2 >= 1){
//					if(powerRatio <=0){
//						usbLevel = 0.0;
//						acLevel = 0.0;
//						lightsLevel = 0.5;
//					}
//					else{
//						while(powerRatio <1 && loadLevel>0.5)
//						{
//							usbLevel = Math.max(usbLevel-0.5,0);
//							acLevel = Math.max(acLevel-0.25,0);
//							lightsLevel = Math.max(lightsLevel-0.25,0.5);
//							powerReqAll = acPreq*acLevel+lightsPreq*lightsLevel+usbPreq*usbLevel;
//							powerRatio = (powerBattAll-autopilotPreq)/powerReqAll;
//							loadLevel = usbLevel+acLevel+lightsLevel;
//							
//						}
//					}
//				}
					
				
				double[] outputLDac=new double[]{vBus, acPreq, price, simTime};
				double[] outputLDautopilot=new double[]{vBus, autopilotPreq, autopilotLevel, simTime};
				double[] outputLDlights=new double[]{vBus, lightsPreq, price, simTime};
				double[] outputLDusb=new double[]{vBus, usbPreq, price, simTime};
				
//				sendMessage("ac",Arrays.toString(outputLDac).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
//				
//				MessageTemplate  msgAC= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("ac", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("improve"));
//				ACLMessage replyAC = receive(msgAC);
//				
//				sendMessage("lights",Arrays.toString(outputLDlights).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
//				
//				MessageTemplate  msgLight= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("lights", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("improve"));
//				ACLMessage replyLight = receive(msgLight);
//				
//				sendMessage("usb",Arrays.toString(outputLDusb).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
//				
//				MessageTemplate  msgUSB= MessageTemplate.and(MessageTemplate.MatchSender(new AID ("usb", AID.ISLOCALNAME)), MessageTemplate.MatchConversationId("improve"));
//				ACLMessage replyUSB = receive(msgUSB);
//				
//				
//				if(replyAC!=null || replyLight!=null || replyUSB!=null){
//					String acInput = replyAC.getContent();
//					double pOutAC = parseAnswerDouble(acInput)[0];
//					double levelAC = parseAnswerDouble(acInput)[1];
//					double perfImproveAC = parseAnswerDouble(acInput)[2];
//					double powerImproveAC = parseAnswerDouble(acInput)[3];
//					
//					String lightInput = replyLight.getContent();
//					double pOutLight = parseAnswerDouble(lightInput)[0];
//					double levelLight = parseAnswerDouble(lightInput)[1];
//					double perfImproveLight = parseAnswerDouble(lightInput)[2];
//					double powerImproveLight = parseAnswerDouble(lightInput)[3];
//					
//					String usbInput = replyUSB.getContent();
//					double pOutUSB = parseAnswerDouble(usbInput)[0];
//					double levelUSB = parseAnswerDouble(usbInput)[1];
//					double perfImproveUSB = parseAnswerDouble(usbInput)[2];
//					double powerImproveUSB = parseAnswerDouble(usbInput)[3];
//					
//					
//					
//					
//					
//					
//					
//					
//					
//				}
				
				sendMessage("autopilot",Arrays.toString(outputLDautopilot).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				sendMessage("ac",Arrays.toString(outputLDac).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				sendMessage("lights",Arrays.toString(outputLDlights).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				sendMessage("usb",Arrays.toString(outputLDusb).replace("[", "").replace("]", ""),"get-output",ACLMessage.INFORM);
				
				output = device + ",mbSlopeAdj,sbSlopeAdj,price,simtime," + Double.toString(mb1SlopeAdj) + "," + Double.toString(sb1SlopeAdj) + "," + Double.toString(price) + "," + simTime;
				
				sendMessage(matlabAgent,output,"send-output",ACLMessage.INFORM);
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
