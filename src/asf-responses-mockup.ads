-----------------------------------------------------------------------
--  asf.responses.mockup -- ASF Response mockup
--  Copyright (C) 2010 Stephane Carrez
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

private with Util.Streams.Texts;
private with Util.Strings.Maps;

--  The <b>ASF.Responses.Mockup</b> provides a fake response object to simulate
--  an HTTP response.
package ASF.Responses.Mockup is

   --  ------------------------------
   --  Response Mockup
   --  ------------------------------
   --  The response mockup implements a fake HTTP response object
   type Response is new ASF.Responses.Response with private;

   --  Adds the specified cookie to the response. This method can be called multiple
   --  times to set more than one cookie.
   procedure Add_Cookie (Resp   : in out Response;
                         Cookie : in String);

   --  Returns a boolean indicating whether the named response header has already
   --  been set.
   function Contains_Header (Resp : in Response;
                             Name : in String) return Boolean;

   --  Iterate over the response headers and executes the <b>Process</b> procedure.
   procedure Iterate_Headers (Resp    : in Response;
                              Process : not null access
                                procedure (Name  : in String;
                                           Value : in String));

   --  Sets a response header with the given name and value. If the header had already
   --  been set, the new value overwrites the previous one. The containsHeader
   --  method can be used to test for the presence of a header before setting its value.
   procedure Set_Header (Resp  : in out Response;
                         Name  : in String;
                         Value : in String);

   --  Adds a response header with the given name and value.
   --  This method allows response headers to have multiple values.
   procedure Add_Header (Resp  : in out Response;
                         Name  : in String;
                         Value : in String);

   --  Get the content written to the mockup output stream.
   procedure Read_Content (Resp : in out Response;
                           Into : out Ada.Strings.Unbounded.Unbounded_String);

private

   --  Initialize the response mockup output stream.
   overriding
   procedure Initialize (Resp : in out Response);

   type Response is new ASF.Responses.Response with record
      Content : aliased Util.Streams.Texts.Print_Stream;
      Headers : Util.Strings.Maps.Map;
   end record;

end ASF.Responses.Mockup;