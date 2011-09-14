-----------------------------------------------------------------------
--  asf-clients -- HTTP Clients
--  Copyright (C) 2011 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

with Ada.Finalization;

with ASF.Cookies;
package ASF.Clients is

   --  ------------------------------
   --  Http response
   --  ------------------------------
   --  The <b>Response</b> type represents a response returned by an HTTP request.
   type Response is tagged limited private;

   --  Returns a boolean indicating whether the named response header has already
   --  been set.
   function Contains_Header (Reply : in Response;
                             Name  : in String) return Boolean;

   --  Returns the value of the specified response header as a String. If the response
   --  did not include a header of the specified name, this method returns null.
   --  If there are multiple headers with the same name, this method returns the
   --  first head in the request. The header name is case insensitive. You can use
   --  this method with any response header.
   function Get_Header (Reply  : in Response;
                        Name   : in String) return String;

   --  Get the response body as a string.
   function Get_Body (Reply : in Response) return String;

   --  Get the response status code.
   function Get_Status (Reply : in Response) return Natural;

   --  ------------------------------
   --  Http client
   --  ------------------------------
   --  The <b>Client</b> type allows to execute HTTP GET/POST requests.
   type Client is tagged limited private;
   type Client_Access is access all Client;

   --  Execute an http GET request on the given URL.  Additional request parameters,
   --  cookies and headers should have been set on the client object.
   procedure Do_Get (Http     : in Client;
                     URL      : in String;
                     Reply    : out Response'Class);

   --  Execute an http POST request on the given URL.  Additional request parameters,
   --  cookies and headers should have been set on the client object.
   procedure Do_Post (Http     : in Client;
                      URL      : in String;
                      Data     : in String;
                      Reply    : out Response'Class);

   --  Adds the specified cookie to the request.  This method can be called multiple
   --  times to set more than one cookie.
   procedure Add_Cookie (Http   : in out Client;
                         Cookie : in ASF.Cookies.Cookie);

   --  Returns a boolean indicating whether the named request header has already
   --  been set.
   function Contains_Header (Http : in Client;
                             Name : in String) return Boolean;

   --  Sets a request header with the given name and value. If the header had already
   --  been set, the new value overwrites the previous one. The containsHeader
   --  method can be used to test for the presence of a header before setting its value.
   procedure Set_Header (Http  : in out Client;
                         Name  : in String;
                         Value : in String);

   --  Adds a request header with the given name and value.
   --  This method allows request headers to have multiple values.
   procedure Add_Header (Http  : in out Client;
                         Name  : in String;
                         Value : in String);

private

   type Http_Request is abstract tagged null record;
   type Http_Request_Access is access all Http_Request'Class;

   --  Returns a boolean indicating whether the named request header has already
   --  been set.
   function Contains_Header (Http : in Http_Request;
                             Name : in String) return Boolean is abstract;

   --  Sets a request header with the given name and value. If the header had already
   --  been set, the new value overwrites the previous one. The containsHeader
   --  method can be used to test for the presence of a header before setting its value.
   procedure Set_Header (Http  : in out Http_Request;
                         Name  : in String;
                         Value : in String) is abstract;

   --  Adds a request header with the given name and value.
   --  This method allows request headers to have multiple values.
   procedure Add_Header (Http  : in out Http_Request;
                         Name  : in String;
                         Value : in String) is abstract;

   type Http_Response is abstract tagged null record;
   type Http_Response_Access is access all Http_Response'Class;

   --  Returns a boolean indicating whether the named response header has already
   --  been set.
   function Contains_Header (Reply : in Http_Response;
                             Name  : in String) return Boolean is abstract;

   --  Returns the value of the specified response header as a String. If the response
   --  did not include a header of the specified name, this method returns null.
   --  If there are multiple headers with the same name, this method returns the
   --  first head in the request. The header name is case insensitive. You can use
   --  this method with any response header.
   function Get_Header (Reply  : in Http_Response;
                        Name   : in String) return String is abstract;

   --  Get the response body as a string.
   function Get_Body (Reply : in Http_Response) return String is abstract;

   type Http_Manager is interface;
   type Http_Manager_Access is access all Http_Manager'Class;

   procedure Create (Manager  : in Http_Manager;
                     Http     : in out Client'Class) is abstract;

   procedure Do_Get (Manager  : in Http_Manager;
                     Http     : in Client'Class;
                     URI      : in String;
                     Reply    : out Response'Class) is abstract;

   procedure Do_Post (Manager  : in Http_Manager;
                      Http     : in Client'Class;
                      URI      : in String;
                      Data     : in String;
                      Reply    : out Response'Class) is abstract;

   Default_Http_Manager : Http_Manager_Access;

   type Response is new Ada.Finalization.Limited_Controlled with record
      Data   : Http_Response_Access;
      Status : Natural := 0;
   end record;

   --  Free the resource used by the response.
   overriding
   procedure Finalize (Reply : in out Response);

   type Client is new Ada.Finalization.Limited_Controlled with record
      Manager  : Http_Manager_Access;
      Request  : Http_Request_Access;
   end record;

   --  Initialize the client
   overriding
   procedure Initialize (Http : in out Client);

   overriding
   procedure Finalize (Http : in out Client);

end ASF.Clients;