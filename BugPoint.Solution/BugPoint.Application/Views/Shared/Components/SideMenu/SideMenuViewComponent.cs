﻿using BugPoint.Data.MenuCategory.Queries;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BugPoint.Application.Views.Shared.Components.SideMenu
{
    public class SideMenuViewComponent : ViewComponent
    {
        private readonly IMenuCategoryQueries _menuCategoryQueries;

        public SideMenuViewComponent(IMenuCategoryQueries menuCategoryQueries)
        {
            _menuCategoryQueries = menuCategoryQueries;
        }

        public IViewComponentResult Invoke()
        {
            var menucategoryList = _menuCategoryQueries.GetCategoryByRoleId(HttpContext.Session.GetInt32("Portal.RoleId"));

            return View(menucategoryList);
        }
    }
}