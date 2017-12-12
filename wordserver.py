import optparse
import threading
import OSC
import string

try: 
    maxServer = OSC.OSCServer(('127.0.0.1', 6002))
    maxServerThread = threading.Thread(target=maxServer.serve_forever)
    maxServerThread.daemon = False
    maxServerThread.start()

    maxClient = OSC.OSCClient()
    maxClient.connect(('127.0.0.1', 1234))

    def sendOSCMessage( addr, *msgArgs):
        msg = OSC.OSCMessage()
        msg.setAddress(addr)
        msg.append(*msgArgs)
        maxClient.send(msg)


    paradiseLostFull = open('paradiseLost.txt').read().split()

    def isTextLine(line):
        return len([s for s in line if s in string.ascii_lowercase]) > 0

    pdCleanedLines = [line for line in paradiseLostFull if isTextLine(line)]

    lineCounter = 0

    def getLine(addr, tags, stuff, source):
        print 'sending new line'
        sendOSCMessage("/nextLine", [pdCleanedLines[stuff[0]]])

    maxServer.addMsgHandler("/getLine", getLine)

    def closeServer(addr, tags, stuff, source):
        maxServer.close()

    maxServer.addMsgHandler("/close", closeServer)

except:
    print "closing"
    maxServer.close()




# class LemurBounce2:
#     def __init__(self):
#         self.superColliderServer = OSC.OSCServer(('127.0.0.1', 7100))
#         self.SCServerThread = threading.Thread(target=self.superColliderServer.serve_forever)
#         self.SCServerThread.daemon = False
#         self.SCServerThread.start()

#         self.superColliderClient = OSC.OSCClient()
#         self.superColliderClient.connect(('127.0.0.1', 57120))

#         self.superColliderServer.addMsgHandler("/funcTrigger", self.funcTriggerResponder)

#         self.visualsServer = OSC.OSCServer(('127.0.0.1', 57121))
#         self.vizServerThread = threading.Thread(target=self.visualsServer.serve_forever)
#         self.vizServerThread.daemon = False
#         self.vizServerThread.start()

#         self.visualsClient = OSC.OSCClient()
#         self.visualsClient.connect(('127.0.0.1', 7400))

#         self.visualsServer.addMsgHandler("/hello", self.testResponder)
#         self.visualsServer.addMsgHandler("/toSC", self.toSCResponder)

#         self.printLog = False;

#         self.triggerFunctions = {}


#     def funcTriggerResponder(self, addr, tags, stuff, source):
#         if stuff[0] in self.triggerFunctions:
#             self.triggerFunctions[stuff[0]]()


#     def sendOSCMessage(self, addr, client=0, *msgArgs):
#         msg = OSC.OSCMessage()
#         msg.setAddress(addr)
#         msg.append(*msgArgs)
#         if (client == 0):
#             self.superColliderClient.send(msg)
#         else:
#             self.visualsClient.send(msg)

#     def toSCResponder(self, addr, tags, stuff, source):
#         address = stuff[0]
#         args = stuff[1:]
#         if self.printLog:
#             print address
#             print args
#         self.sendOSCMessage(address, 0, args)

#     def testResponder(self, addr, tags, stuff, source):
#         print stuff
#         self.sendOSCMessage('/test', 1, ['Did you get this message?', 'Didja?'])

