const express = require("express");
const http = require("http");
const cors = require("cors");

const app = express();
const port = process.env.PORT || 3001;
const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: {
    origin: "*",
  },
});


app.use(express.json());
app.use(cors());

try {
  io.on("connection", (socket) => {
    console.log("baglandı");
    console.log(socket.id, "katildi");
    
    socket.on('testEvent', (data) => {
      print('Sunucudan gelen veri: $data');
      
    });
    

  
    app.post("/test", (req, res) => {
      const receivedData = req.body;
      console.log("gelen veri /test endpoint:", receivedData);

      
      io.emit("testEvent", receivedData); 
      res.status(200).json({ success: true, message: "veri alindi", msg: req.body.msg, id: req.body.phone });
    });
  });
} catch (error) {
  console.log(error);
}

server.listen(port, () => {
  console.log("server baslatildi. port", port);
});
