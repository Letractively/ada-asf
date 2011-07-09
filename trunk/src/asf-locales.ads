-----------------------------------------------------------------------
--  asf-factory -- Component and tag factory
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

with Util.Beans.Objects;
with Util.Beans.Basic;
with Util.Strings.Maps;
with Util.Properties.Bundles;
with ASF.Beans;

--  The <b>ASF.Locales</b> package manages everything related to the locales.
--  It allows to register bundles that contains localized messages and be able
--  to use the in the facelet views.
package ASF.Locales is

   type Bundle is new Util.Properties.Bundles.Manager
     and Util.Beans.Basic.Readonly_Bean with null record;
   type Bundle_Access is access all Bundle;

   --  Get the value identified by the name.
   --  If the name cannot be found, the method should return the Null object.
   function Get_Value (From : in Bundle;
                       Name : in String) return Util.Beans.Objects.Object;

   type Factory is limited private;

   --  Initialize the locale support by using the configuration properties.
   --  Properties matching the pattern: <b>bundles</b>.<i>var-name</i>=<i>bundle-name</i>
   --  are used to register bindings linking a facelet variable <i>var-name</i>
   --  to the resource bundle <i>bundle-name</i>.
   procedure Initialize (Fac    : in out Factory;
                         Beans  : in out ASF.Beans.Bean_Factory;
                         Config : in Util.Properties.Manager'Class);

   --  Register a bundle and bind it to a facelet variable.
   procedure Register (Fac    : in out Factory;
                       Beans  : in out ASF.Beans.Bean_Factory;
                       Name   : in String;
                       Bundle : in String);

   --  Load the resource bundle identified by the <b>Name</b> and for the given
   --  <b>Locale</b>.
   procedure Load_Bundle (Fac    : in out Factory;
                          Name   : in String;
                          Locale : in String;
                          Result : out Bundle);

private

   type Factory is limited record
      Factory : aliased Util.Properties.Bundles.Loader;
      Bundles : Util.Strings.Maps.Map;
   end record;

   type Factory_Access is access all Factory;

end ASF.Locales;