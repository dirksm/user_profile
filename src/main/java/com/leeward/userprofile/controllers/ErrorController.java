package com.leeward.userprofile.controllers;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/error")
public class ErrorController {

	@RequestMapping(value="/400")
	public String process400Error(ModelMap map) {
		return "error.400";
	}

	
	@RequestMapping(value="/401")
	public String process401Error(ModelMap map, HttpServletRequest request) {
		request.getSession().invalidate();
		return "error.401";
	}
	
	@RequestMapping(value="/403")
	public String process403Error(ModelMap map, HttpServletRequest request) {
		request.getSession().invalidate();
		return "error.403";
	}
	
	@RequestMapping(value="/404")
	public String process404Error(ModelMap map) {
		return "error.404";
	}

	@RequestMapping(value="/405")
	public String process405Error(ModelMap map) {
		return "error.405";
	}

	@RequestMapping(value="/500")
	public String process500Error(ModelMap map) {
		return "error.500";
	}
	
}
