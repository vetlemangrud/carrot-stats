const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  PutCommand,
  ScanCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = "Carrots";

exports.handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));

  const { httpMethod, path } = event;

  try {
    switch (httpMethod) {
      case "POST":
        return await createCarrot();
      case "GET":
        return await getAllCarrots();
      default:
        return {
          statusCode: 405,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
          body: JSON.stringify({ message: "Method not allowed" }),
        };
    }
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({
        message: "Internal server error",
        error: error.message,
      }),
    };
  }
};

async function createCarrot() {
  const now = new Date().toISOString();
  const carrotId = `carrot-${Date.now()}-${Math.random()
    .toString(36)
    .substr(2, 9)}`;

  const params = {
    TableName: TABLE_NAME,
    Item: {
      CarrotId: carrotId,
      EatTimestamp: now,
    },
  };

  await ddbDocClient.send(new PutCommand(params));

  return {
    statusCode: 201,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    body: JSON.stringify({
      message: "Carrot created successfully",
      carrot: params.Item,
    }),
  };
}

async function getAllCarrots() {
  const params = {
    TableName: TABLE_NAME,
  };

  const result = await ddbDocClient.send(new ScanCommand(params));

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    body: JSON.stringify({
      message: "Carrots retrieved successfully",
      carrots: result.Items || [],
      count: result.Count || 0,
    }),
  };
}
