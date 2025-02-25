exports.handler = async (event) => {
  console.log("Appointment service triggered", event);
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from Appointment Service!",
    }),
  };
};
