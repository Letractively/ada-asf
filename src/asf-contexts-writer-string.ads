-----------------------------------------------------------------------
--  writer.string -- A simple string writer
--  Copyright (C) 2009, 2010, 2011 Stephane Carrez
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

with Util.Streams.Texts;

--  Implements a <b>ResponseWriter</b> that puts the result in a string.
--  The response content can be retrieved after the response is rendered.
package ASF.Contexts.Writer.String is

   --  ------------------------------
   --  String Writer
   --  ------------------------------
   type String_Writer is new Response_Writer with private;

   procedure Initialize (Stream : in out String_Writer);

   --  Get the response
   function Get_Response (Stream : in String_Writer) return Unbounded_String;

private

   type String_Writer is new Response_Writer with record
      Content  : aliased Util.Streams.Texts.Print_Stream;
   end record;

end ASF.Contexts.Writer.String;
