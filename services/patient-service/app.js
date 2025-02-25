exports.handler = async (event) => {
  console.log("Patient service triggered", event);
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from Patient Service!",
    }),
  };
};
