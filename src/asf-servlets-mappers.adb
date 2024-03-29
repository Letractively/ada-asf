-----------------------------------------------------------------------
--  asf-servlets-mappers -- Read servlet configuration files
--  Copyright (C) 2011, 2012, 2013 Stephane Carrez
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

with EL.Utils;

package body ASF.Servlets.Mappers is

   --  ------------------------------
   --  Save in the servlet config object the value associated with the given field.
   --  When the <b>FILTER_MAPPING</b>, <b>SERVLET_MAPPING</b> or <b>CONTEXT_PARAM</b> field
   --  is reached, insert the new configuration rule in the servlet registry.
   --  ------------------------------
   procedure Set_Member (N     : in out Servlet_Config;
                         Field : in Servlet_Fields;
                         Value : in Util.Beans.Objects.Object) is
      use Util.Beans.Objects;
   begin
      --  <context-param>
      --    <param-name>property</param-name>
      --    <param-value>false</param-value>
      --  </context-param>
      --  <filter-mapping>
      --    <filter-name>Dump Filter</filter-name>
      --    <servlet-name>Faces Servlet</servlet-name>
      --  </filter-mapping>
      case Field is
         when FILTER_NAME =>
            N.Filter_Name := Value;

         when SERVLET_NAME =>
            N.Servlet_Name := Value;

         when URL_PATTERN =>
            N.URL_Pattern := Value;

         when PARAM_NAME =>
            N.Param_Name := Value;

         when PARAM_VALUE =>
            N.Param_Value := EL.Utils.Eval (To_String (Value), N.Context.all);

         when MIME_TYPE =>
            N.Mime_Type := Value;

         when EXTENSION =>
            N.Extension := Value;

         when ERROR_CODE =>
            N.Error_Code := Value;

         when LOCATION =>
            N.Location := Value;

         when FILTER_MAPPING =>
            N.Handler.Add_Filter_Mapping (Pattern => To_String (N.URL_Pattern),
                                          Name    => To_String (N.Filter_Name));

         when SERVLET_MAPPING =>
            N.Handler.Add_Mapping (Pattern => To_String (N.URL_Pattern),
                                   Name    => To_String (N.Servlet_Name));

         when CONTEXT_PARAM =>
            declare
               Name : constant String := To_String (N.Param_Name);
            begin
               --  If the context parameter already has a value, do not set it again.
               --  The value comes from an application setting and we want to keep it.
               if N.Handler.Get_Init_Parameter (Name) = "" then
                  if Util.Beans.Objects.Is_Null (N.Param_Value) then
                     N.Handler.Set_Init_Parameter (Name  => Name,
                                                   Value => "");
                  else
                     N.Handler.Set_Init_Parameter (Name  => Name,
                                                   Value => To_String (N.Param_Value));
                  end if;
               end if;
            end;

         when MIME_MAPPING =>
            null;

         when ERROR_PAGE =>
            N.Handler.Set_Error_Page (Error => To_Integer (N.Error_Code),
                                      Page  => To_String (N.Location));

      end case;
   end Set_Member;

   SMapper : aliased Servlet_Mapper.Mapper;

   --  ------------------------------
   --  Setup the XML parser to read the servlet and mapping rules <b>context-param</b>,
   --  <b>filter-mapping</b> and <b>servlet-mapping</b>.
   --  ------------------------------
   package body Reader_Config is
   begin
      Reader.Add_Mapping ("faces-config", SMapper'Access);
      Reader.Add_Mapping ("module", SMapper'Access);
      Reader.Add_Mapping ("web-app", SMapper'Access);
      Config.Handler := Handler;
      Config.Context := Context;
      Servlet_Mapper.Set_Context (Reader, Config'Unchecked_Access);
   end Reader_Config;

begin
   SMapper.Add_Mapping ("filter-mapping", FILTER_MAPPING);
   SMapper.Add_Mapping ("filter-mapping/filter-name", FILTER_NAME);
   SMapper.Add_Mapping ("filter-mapping/servlet-name", SERVLET_NAME);
   SMapper.Add_Mapping ("filter-mapping/url-pattern", URL_PATTERN);

   SMapper.Add_Mapping ("servlet-mapping", SERVLET_MAPPING);
   SMapper.Add_Mapping ("servlet-mapping/servlet-name", SERVLET_NAME);
   SMapper.Add_Mapping ("servlet-mapping/url-pattern", URL_PATTERN);

   SMapper.Add_Mapping ("context-param", CONTEXT_PARAM);
   SMapper.Add_Mapping ("context-param/param-name", PARAM_NAME);
   SMapper.Add_Mapping ("context-param/param-value", PARAM_VALUE);

   SMapper.Add_Mapping ("error-page", ERROR_PAGE);
   SMapper.Add_Mapping ("error-page/error-code", ERROR_CODE);
   SMapper.Add_Mapping ("error-page/location", LOCATION);

end ASF.Servlets.Mappers;
