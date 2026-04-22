import {setGlobalOptions} from "firebase-functions";
import {onRequest} from "firebase-functions/v2/https";
import {defineString} from "firebase-functions/params";

setGlobalOptions({maxInstances: 10});

// 🔐 قراءة البيانات من .env
const paymobApiKey = defineString("PAYMOB_API_KEY");
const integrationId = defineString("PAYMOB_INTEGRATION_ID");

// 🚀 Function بسيطة للتجربة
export const getPaymobData = onRequest((req, res) => {
  const apiKey = paymobApiKey.value();
  const integration = integrationId.value();

  res.json({
    apiKey,
    integration,
  });
});
