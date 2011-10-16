/*
 *  asf -- Ada Server Faces
 *  Copyright (C) 2009, 2010, 2011 Stephane Carrez
 *  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
var ASF = {};

(function () {
    /**
     * Execute the AJAX response action represented by the JSON object <b>action</b>.
     *
     * @param node the current node
     * @param action the JSON action object
     */
    ASF.ExecuteOne = function(node, action) {
        if (action.action === "update") {
	    $(action.id).html(action.data);

        } else if (action.action === "show") {
            $(action.id).show('slow');

        } else if (action.action === "hide") {
            $(action.id).hide('slow');

        } else if (action.action === "delete") {
	    $(action.id).remove();

        } else if (action.action === "removeClass") {
	    $(action.id).removeClass(action.data);

        } else if (action.action === "addClass") {
	    $(action.id).addClass(action.data);

        } else if (action.action === "fadeIn") {
            $(action.id).fadeIn('slow');

        } else if (action.action === "fadeOut") {
            $(action.id).fadeOut('slow');

        } else if (action.action === "slideUp") {
            $(action.id).slideUp('slow');

        } else if (action.action === "slideDown") {
            $(action.id).slideDown('slow');

        } else if (action.action === "redirect") {
            document.location = action.url;
	}
    };

    ASF.Execute = function(node, data) {
        if (data != null) {
            for (var i = 0; i < data.length; i++) {
                ASF.ExecuteOne(node, data[i]);
            }
        }
    };
    
    /**
     * Update the target container with the content of the AJAX GET request
     * on the given URL.  The target parameter is optional.
     *
     * @param node the current element
     * @param url the URL to fetch using an HTTP GET
     * @param target the optional target element
     */
    ASF.Update = function(node, url, target) {
        /* Find the container to update */
        var d;
        if (target != null) {
            d = $(target);
        } else {
            d = $(node);
            if (!d.is('.asf-container')) {
                d = d.parent('.asf-container');
            }
        }
        if (d.length > 0) {
            /* Perform the HTTP GET */
            jQuery.ajax({
                url: url,
                context: document.body,
                success: function(data, status, jqXHDR) {
                    var contentType = jqXHDR.getResponseHeader('Content-type');
                    if (contentType == null) {
                        contentType = "text/html";
                    }
                    if (contentType.match(/^text\/(html|xml)(;.*)?$/i)) {
                        d.html(jqXHDR.responseText);

                    } else if (contentType.match(/^application\/json(;.*)?$/i)) {
                        ASF.Execute(node, data);
                    }
               }
            });
        }
    };
 
    
})();
