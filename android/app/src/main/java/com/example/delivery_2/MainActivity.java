package com.example.delivery_2;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;
import java.io.UnsupportedEncodingException;
import java.sql.Date;
import java.text.SimpleDateFormat;

import gems.com.command.sdk.Font;
import gems.com.command.sdk.TextUtil;
import gems.com.command.sdk.PrinterCommand;
import gems.com.command.sdk.Command;


//import zj.com.customize.sdk.Other;

import java.util.ArrayList;
import java.util.List; 
import org.json.JSONArray;
import org.json.JSONObject;


public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "flutter.native/helper";
  private static final String TAG = "Main_Activity";
  private static final boolean DEBUG = true;
  
  private BluetoothAdapter mBluetoothAdapter = null;
  private BluetoothService mService = null;
  private String mConnectedDeviceName = null;

  public static final String DEVICE_NAME = "device_name";
  public static final String TOAST = "toast";

  public static final int MESSAGE_STATE_CHANGE = 1;
  public static final int MESSAGE_READ = 2;
  public static final int MESSAGE_WRITE = 3;
  public static final int MESSAGE_DEVICE_NAME = 4;
  public static final int MESSAGE_TOAST = 5;
  public static final int MESSAGE_CONNECTION_LOST = 6;
  public static final int MESSAGE_UNABLE_CONNECT = 7;

  private static final int REQUEST_CONNECT_DEVICE = 1;
  private static final int REQUEST_ENABLE_BT = 2;
  private static final int REQUEST_CHOSE_BMP = 3;
  private static final int REQUEST_CAMER = 4;

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    if (DEBUG)
          Log.e(TAG, "+++ ON CREATE +++");

          // Get local Bluetooth adapter
          if (Build.VERSION.SDK_INT >= VERSION_CODES.ECLAIR) {
            mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
          }
          //Toast.makeText(this, "Bluetooth available", Toast.LENGTH_LONG).show();
          // If the adapter is null, then Bluetooth is not supported
          if (mBluetoothAdapter == null) {
            //Toast.makeText(this, "Bluetooth is not available", Toast.LENGTH_LONG).show();
            finish();
          }

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler((call, result) -> {

            switch (call.method) {
                case "helloFromNativeCode":
                String greetings = helloFromNativeCode();
                result.success(greetings);
                    break;

                case "startScan":
                String macAddress = call.argument("macAddress");
                String scan = startScan(macAddress);
                    break;

                case "multi_lang_test":
                Log.i(TAG,"multi");
                List detailData = call.argument("detail");
                List invDetailData = call.argument("invDetail");
                List headerData = call.argument("header");
                String bName = call.argument("bName");
                multiLanguagePrint(detailData, invDetailData,headerData,bName);
                    break;   

                default:
                    break;
            }
            // return "scan";
          
        });
  }

  @Override
  public synchronized void onResume() {
    super.onResume();

    if (mService != null) {

      if (mService.getState() == BluetoothService.STATE_NONE) {
        // Start the Bluetooth services(�?后台)
        mService.start();
      }
    }
  }

  @Override
  public synchronized void onPause() {
    super.onPause();
    if (DEBUG)
      Log.e(TAG, "- ON PAUSE -");
  }

  @Override
  public void onStop() {
    super.onStop();
    if (DEBUG)
      Log.e(TAG, "-- ON STOP --");
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    // Stop the Bluetooth services
    if (mService != null)
      mService.stop();
    if (DEBUG)
      Log.e(TAG, "--- ON DESTROY ---");
  }

  private String helloFromNativeCode() {

    if (Build.VERSION.SDK_INT >= VERSION_CODES.ECLAIR) {
      if (!mBluetoothAdapter.isEnabled()) {
        Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
         startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        // Otherwise, setup the session
      } else {
        if (mService == null)
        Log.i(TAG, "Log call init ");
          //Toast.makeText(this, "call init", Toast.LENGTH_LONG).show();
        init();// 监听
      }
    }
    return "Hello from Native Android Code";
  }

  private void init() {
    mService = new BluetoothService(this, mHandler);
  }

  private String startScan(String macAddress){
    // String address = "F4:5E:AB:D9:71:46";
    // String address = "50:65:83:8C:84:5C";
    Log.i("MAC address",macAddress);

    Log.i(TAG, "Result OK " );
    if (Build.VERSION.SDK_INT >= VERSION_CODES.ECLAIR) {

      if (BluetoothAdapter.checkBluetoothAddress(macAddress)) {
        Log.i(TAG,"Connected");
        BluetoothDevice device = mBluetoothAdapter
                .getRemoteDevice(macAddress);
        // Attempt to connect to the device
        mService.connect(device);
      }
    }
    return "start Scan";
  }

  private void multiLanguagePrint(List detail, List invDetailList, List header,String bName){

    String dataToPrint = "";
    String space = "";
  
     try {
  
      Font font=new Font();
       font.setSize(14);
       //font.setAlign(font.ALIGN_RIGHT);
       font.setStrokeWidth(5);
       font.settByte(1);
       font.setHeader(1.5f);
       font.setFoot(1.5f);
       font.setLine(0.1f);
  
       byte[] buffer = PrinterCommand.POS_Set_PrtInit();
       byte[] goPrint=null;
  
       TextUtil tu=new TextUtil();
  
      JSONArray detailList = new JSONArray(detail);
      JSONArray invdetailList = new JSONArray(invDetailList);
      JSONArray headerList = new JSONArray(header);
  
      dataToPrint += ("@_C" + bName + ";;");
  
      for(int j = 0;j<headerList.length();j++){
        JSONObject headerData = headerList.getJSONObject(j);
  
       String Store = headerData.getString("Store");
       String StoreID = headerData.getString("Store_ID");
       String StoreMM = headerData.getString("StoreNameMM");
       String Tel = headerData.getString("Tel");
       String PreSellerName = headerData.getString("Preseller");
       String User_Name = headerData.getString("User_Name");
       String Invoice_No = headerData.getString("Invoice_No");
       String Print_Date = headerData.getString("Print_Date");
       String Invoice_Date = headerData.getString("Invoice_Date");
       String Sub_Total = headerData.getString("Sub_Total");
       String Special_Discount_Amount = headerData.getString("Special_Discount_Amount");
       String Expired_Amount = headerData.getString("Expired_Amount");
       JSONArray AccountList = headerData.getJSONArray("AccountList");
       String Cash_Amount = headerData.getString("Cash_Amount");
       String Credit_Amount = headerData.getString("Credit_Amount");
       String Total_Amount = headerData.getString("Total_Amount");
       String Total_Amount_Percent = headerData.getString("Total_Amount_Percent");
       JSONArray Additional_Cash = headerData.getJSONArray("Additional_Cash");
       String Street = headerData.getString("Street");
  
      dataToPrint += ("Store  :  " + Store + ";");
  
      dataToPrint += ("Store ID  :  " + StoreID + ";");
  
      dataToPrint += ("ဆိုင်  :  " + StoreMM + ";");
  
      dataToPrint += ("Tel  :  " + Tel + ";");
  
      dataToPrint += ("Preseller  :  " + PreSellerName + ";");
  
      dataToPrint += ("User Name  :  " + User_Name + ";");
  
      dataToPrint += ("Invoice No  :  " + "1" + ";");
  
      dataToPrint += ("Print Date  :  " + Print_Date + ";");
  
      dataToPrint += ("Invoice Date  :  " + Invoice_Date + ";");
  
      dataToPrint += ("-------------------------------------------------------------------------------------------------------------------;");
  
      dataToPrint += ("SKU->Selling->Normal->Qty->Amount;");
  
      for(int i=0;i<detailList.length();i++){
        JSONObject detailData = detailList.getJSONObject(i);
  
        String dStkDesc = detailData.getString("stkDesc");
        String dQty = detailData.getString("totalqty");
        String dNormalPrice = detailData.getString("standardPrice");
        String dSellingPrice = detailData.getString("sellingPrice");
        String dTotal = detailData.getString("totalAmount");
  
        dataToPrint +=  dStkDesc + "->" + dSellingPrice + "->" + dNormalPrice + "->" + dQty + "->" + dTotal + ";";
      }
  
      for(int i=0;i<invdetailList.length();i++){
        JSONObject detailData = invdetailList.getJSONObject(i);
  
        String dStkDesc = detailData.getString("stkDesc");
        String dQty = detailData.getString("totalqty");
        String dNormalPrice = detailData.getString("standardPrice");
        String dSellingPrice = detailData.getString("sellingPrice");
        String dTotal = detailData.getString("totalAmount");
  
        dataToPrint +=  dStkDesc + "->" + dSellingPrice + "->" + dNormalPrice + "->" + dQty + "->" + dTotal + ";";
      }
    
      dataToPrint += ("-------------------------------------------------------------------------------------------------------------------;");
      
      dataToPrint += "SubTotal->" + Sub_Total + ";" ;
  
      dataToPrint += "Special Discount Amount->" + Special_Discount_Amount + ";" ;
  
      dataToPrint += "Expired Amount->" + Expired_Amount + ";" ;
  
      for(int i=0;i<AccountList.length();i++){
        JSONObject detailData = AccountList.getJSONObject(i);
  
        String accountName = detailData.getString("AccountName");
        String accountValue = detailData.getString("AccountValue");
  
        dataToPrint += accountName + "->" + accountValue + ";" ;
      }
  
      dataToPrint += "Cash Amount->" + Cash_Amount + ";" ;
  
      dataToPrint += "Credit Amount->" + Credit_Amount + ";" ;
      
      dataToPrint += ("-------------------------------------------------------------------------------------------------------------------;");
  
      dataToPrint += "Total Amount" + Total_Amount_Percent + "->" + Total_Amount + ";" ;
  
      dataToPrint += ("-------------------------------------------------------------------------------------------------------------------;");
  
      for(int i=0;i<Additional_Cash.length();i++){
        JSONObject detailData = Additional_Cash.getJSONObject(i);
  
        String value = detailData.getString("value");
  
        dataToPrint += "Additional Cash->" + value + ";" ;
  
        dataToPrint += ("-------------------------------------------------------------------------------------------------------------------;");
      
      }
      
      }
        dataToPrint += ("@_CThank You !" + ";");
        
        dataToPrint += ("@_C"+ bName + " supported by Auderbox" + ";");
  
        // dataToPrint += ("@_C"+ bName +" Hotline : 09770288882" + ";");
  
       Log.i(TAG,dataToPrint);
       
       goPrint = tu.drawCanvas(dataToPrint,25,120,18,575);
       sendDataByte2BT(goPrint);
       
       sendDataByte2BT(new byte[] { 0x1b, 0x4a, 0x30, 0x1d, 0x56, 0x42, 0x01 });
  
     } catch (Exception e) {
       // TODO: handle exception
       Log.e("multi_error",e.getMessage());
     }
    }

  private void sendDataByte2BT(byte[] data) {

    if (mService.getState() != BluetoothService.STATE_CONNECTED) {
      Toast.makeText(this, "Please connect a bluetooth printer", Toast.LENGTH_SHORT)
              .show();
      return;
    }
    mService.write(data);
  }

  private final Handler mHandler = new Handler() {
    @Override
    public void handleMessage(Message msg) {
      // Toast.makeText(this, "handle Message", Toast.LENGTH_LONG).show();
      switch (msg.what) {
        case MESSAGE_STATE_CHANGE:
          if (DEBUG)
            Log.i(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
          switch (msg.arg1) {
            case BluetoothService.STATE_CONNECTED:
              //Print_Test();
              //Toast.makeText(getApplicationContext(), "Connected" + msg.arg1, Toast.LENGTH_LONG).show();
              Log.i(TAG, "Connected "+msg.arg1);

              break;
            case BluetoothService.STATE_CONNECTING:
              Toast.makeText(getApplicationContext(), "Connecting", Toast.LENGTH_LONG).show();
              // mTitle.setText(R.string.title_connecting);
              Log.i(TAG, "Connecting "+msg.arg1);

              break;
            case BluetoothService.STATE_LISTEN:
            case BluetoothService.STATE_NONE:
              //Toast.makeText(getApplicationContext(), "Not Connected", Toast.LENGTH_LONG).show();
              // mTitle.setText(R.string.title_not_connected);
              Log.i(TAG, "Not Connected "+msg.arg1);

              break;
          }
          break;
        case MESSAGE_WRITE:

          break;
        case MESSAGE_READ:

          break;
        case MESSAGE_DEVICE_NAME:
          mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
          Toast.makeText(getApplicationContext(), "Connected to " + mConnectedDeviceName, Toast.LENGTH_SHORT).show();          
          Log.i(TAG, "Connected to " + mConnectedDeviceName);          
          break;
        case MESSAGE_TOAST:
          Toast.makeText(getApplicationContext(), msg.getData().getString(TOAST), Toast.LENGTH_SHORT).show();
          Log.i(TAG, msg.getData().getString(TOAST));
          break;
        case MESSAGE_CONNECTION_LOST:
          Toast.makeText(getApplicationContext(), "Device connection was lost", Toast.LENGTH_SHORT).show();
          Log.i(TAG, "Device connection was lost");
          break;
        case MESSAGE_UNABLE_CONNECT:
          Toast.makeText(getApplicationContext(), "Unable to connect device", Toast.LENGTH_SHORT).show();
          Log.i(TAG, "Unable to connect device");
          break;
      }
    }
  };

}
