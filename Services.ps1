
#if(! [string]::IsNullOrWhiteSpace($name_Service)){
    #Write-Host "Esta bien"
#}

#Buscar Servicio por nombre 
function BuscarServicio ([string]$p_Name = $null) {
    if(! [string]::IsNullOrWhiteSpace($p_Name)){
        Get-Service -Name *$p_Name*
    }Else{
        Get-Service
    }
}

#Lista los servicios
function ListarProcesos ($p_nameService,$p_colorResult,$p_Estado) {

    if((BuscarServicio $p_nameService).Length -gt 0){
        if(( (BuscarServicio $p_nameService) | Where-Object {$_.Status -eq $p_Estado}).Length -gt 0){
                Write-Host -ForegroundColor $p_colorResult "Servicios $p_Estado encontrados: " ( (BuscarServicio $p_nameService) | Where-Object {$_.Status -eq $p_Estado}).Length
                (BuscarServicio $p_nameService) | Select-Object Name,DisplayName,Status | Where-Object {$_.Status -eq $p_Estado} | Format-Table -AutoSize 
        }  
    }
}

<#
    Funciones de menu
#>

#Menu BUscar Servicio por Nombre
function Menu_BuscarServicioPorNombre(){

    [string]$nameService= Read-Host "Ingrese el nombre del servicio"

    if(![string]::IsNullOrWhiteSpace($nameService)){

        Write-Host -ForegroundColor DarkYellow "Total servicios encontrados: " (Get-Service -Name *$nameService*).Length
        ListarProcesos $nameService "DarkGreen" "Running"
        ListarProcesos $nameService "DarkRed" "Stopped"
        
        <#
        # No puedo usar la variable $Services no se porque, falta investigar 
        #$Services =  (Get-Service -Name *$nameService* | Select Name,DisplayName,Status | Sort-Object status -descending)
        if($Services.GetType().IsArray){
            if($Services.Length -gt 0){
			
                 Write-Host -ForegroundColor DarkYellow "Total servicios encontrados: " $Services.Length  
                #Verifica si hay registros Activos
                if( ($Services | Where-Object {$_.Status -eq "Running"}).Length -gt 0){
                    Write-Host -ForegroundColor DarkGreen "Servicios Running encontrados: " ($Services | Where-Object {$_.Status -eq "Running"}).Length
                    $Services | Where-Object {$_.Status -eq "Running"} | Format-Table -AutoSize 
                }
				
				#Stopped
				
				(Get-Service -Name *SQL* | Where-Object {$_.Status -eq "Stopped"}).Length
				
				$Services
				$Services | Where-Object {$_.Status -eq "Stopped" -or $_.Status -eq "Running"}
				
				if( ($Services | Where-Object {$_.Status -eq "Stopped"}).Length -gt 0)
				{
					Write-Host "Xd"
				}
				
                $Services = $null; 
                $Services = ($Services | Where-Object {$_.Status -eq "Stopped"} | Format-Table -AutoSize )
                    
                   $result = ($Services | Where {$_.Status -eq "Stopped"})
                   Write-Host $result.Length
                   return

                   $Services | Where-Object {$_.Status -eq "Stopped"}

                if( ($Services | Where-Object {$_.Status -eq "Stopped"}).Length -gt 0){
                    Write-Host -ForegroundColor DarkRed "Servicios Stopped encontrados: " ($Services | Where-Object {$_.Status -eq "Stopped"}).Length
                    $Services | Where-Object {$_.Status -eq "Stopped"} | Format-Table -AutoSize 
                }


                 #$Services | Format-Table -AutoSize 
				 
            }
        }
        #>
    }
}

#Menu Buscar todos los servicios
function Menu_BuscarTodosLosServicios () {
    Write-Host -ForegroundColor DarkGreen "Servicios encontrados: " (BuscarServicio).Length
    BuscarServicio | Select-Object Name,DisplayName,Status | Sort-Object Status -descending | Format-Table -AutoSize
}

function Menu_DeternerUnServicio () {
    Write-Host -ForegroundColor DarkYellow "DEBE INGRESAR EL NOMBRE EXACTO DEL SERVICIO."; 

    [string]$nameService= Read-Host "Ingrese el nombre del servicio"
    
    if(![string]::IsNullOrWhiteSpace($nameService)){
        $Services = BuscarServicio $nameService
        if($Services.GetType().IsArray){
            if($Services.Length -eq 1){
                Write-Host $Services; 
            }else 
            {
                ListarProcesos $nameService "DarkGreen" "Running"
            }
        }
    }
}


do{
    #Clear-Host;
    Write-Host  -ForegroundColor Cyan ":::::::::::::: Menu principal ::::::::::::::"
    Write-Output "1. Buscar servicios."
    Write-Output "2. Detener servicio."
    Write-Output "3. Iniciar servicio."
    Write-Output "4. Salir."

    $op = 0
    do{
    }until([int]::TryParse((Read-Host 'Que quieres hacer?'),[ref]$op))

    switch ($op)
    {

       1 {
           do{
               
            #Clear-Host;
            Write-Host  -ForegroundColor Cyan ":::::::::::::: Menu buscar servicios ::::::::::::::"
            Write-Output "1. Buscar servicios por nombre."; 
            Write-Output "2. Buscar todos los servicios."; 
            Write-Output "3. Volver a menu principal.";

            $op1 = 0
            do{
            }until([int]::TryParse((Read-Host 'Que quieres hacer?'),[ref]$op1))

            switch($op1){
                #Buscar por nombre
                1 {
                        Menu_BuscarServicioPorNombre
                }
                #Buscar todos los servicios
                2{
                        Menu_BuscarTodosLosServicios
                }
                #Salir al menu princial
                3 {
                    $op1 = -1
                }
                default { Write-Host -ForegroundColor DarkYellow "La opcion digitada [$op1] no es valida" }
            }

           }while($op1 -ne -1)

       }
       2 {
           do{
                Write-Host -ForegroundColor Cyan ":::::::::::::: Detener servicios servicios ::::::::::::::"
                Write-Output "1. Detener un servicio."; 
                Write-Output "2. Detener varios servicios."; 
                Write-Output "3. Salir."; 

                $op1 = 0; 
                do{
                }until([int]::TryParse((Read-Host 'Que quieres hacer?'),[ref]$op1))

                switch ($op1) {
                    1 {
                        Menu_DeternerUnServicio
                    }
                    3 { $op1 = -1 }
                    Default { Write-Host -ForegroundColor DarkYellow "La opcion digitada [$op1] no es valida"}
                }
            }while($op1 -ne -1)
        }
       4 {
           $op = -1
       }
       default {  
            Write-Host -ForegroundColor DarkYellow "La opcion digitada [$op] no es valida"  
        } 
    }
} while($op -ne -1)

