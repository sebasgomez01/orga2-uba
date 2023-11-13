/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"
#include "defines.h"
#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
    if(next_free_kernel_page >= identity_mapping_end) {
        return;
    }
    paddr_t next_free_page;
    next_free_page = next_free_kernel_page;
    next_free_kernel_page += PAGE_SIZE;
    return next_free_page;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
    if(next_free_user_page >= user_memory_pool_end) {
        return;
    }
    paddr_t next_free_page;
    next_free_page = next_free_user_page;
    next_free_user_page += PAGE_SIZE;
    return next_free__page;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
    /*
    for (int i = 0; i < identity_mapping_end; i += 8) {

    }
    */
    // Limpio el contenido del directorio de páginas y de la tabla de páginas 0 del kernel
    zero_page(KERNEL_PAGE_DIR);
    zero_page(KERNEL_PAGE_TABLE_0);

    // Defino la única entrada del page directory
    kpd[0].attrs = MMU_W | MMU_P;
    kpd[0].pt = ((uint32_t)kpt >> 12); // ¿esto no debería ser ?
    // kpt es la entrada 0 del kernel page table, osea tiene un descriptor de página,
    // entonces no entiendo porque inicializa kpd[0].pt como los 20 bits de kpt

    for (int i = 0; i < 1024; i++){
        kpt[i].attrs = MMU_W | MMU_P;
        kpt[i].page = i;
    }

    return kpd; // no estoy seguro de que deba devolver kpd por un tema de tipos de dato
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */

/* Dirección virtual de 32 bits = || dir page offset | page table offset || page frame offset */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
    pd_entry_t* page_directory_address;
    page_directory_address = (pd_entry_t*) CR3_TO_PAGE_DIR(virt);
    uint32_t index_page_directory_entry : 20;
    index_page_directory_entry = VIRT_PAGE_DIR(virt);
    uint32_t index_page_table_entry : 20;
    index_page_table_entry = VIRT_PAGE_TABLE(virt);
    uint32_t page_frame_offset : 12;
    page_frame_offset = VIRT_PAGE_OFFSET(virt);
    uint32_t base_page_frame : 20;
    base_page_frame = phy - page_frame_offset;

    // Defino la page directory entry
    page_directory_address[index_page_directory_entry].attrs = attrs;
    page_directory_address[index_page_directory_entry].pt = kpt;

    // Defino la page table entry
    kpt[index_page_table_entry].attrs = attrs;
    kpt[index_page_table_entry].page = base_page_frame; 

    tlbflush();
}

// Duda sobre la función mmu_unmap_page:
// Tengo que declarar unas estructuras pd_entry_t y pt_entry_t nuevas?
// O tengo usar kpd y kpt?
// Tengo que asignar attrs a ambas estructuras de esa forma o solo a la page table entry?


/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
    // La idea es obtener la dirección física de la página y usar zero_page(phys_address) para limpiarla
    
    // Obtengo el page table entry correspondiente
    pt_entry_t page_table_entry;
    page_table_entry = VIRT_PAGE_TABLE(virt);
    // Obtengo la dirección donde empieza la página
    paddr_t page_base_address;
    page_base_address = page_table_entry.page;
    // Me guardo la dirección física que tengo que retornar
    paddr_t page_offset;
    page_offset = VIRT_PAGE_OFFSET(virt); 
    paddr_t phy_page_start = page_base_address + page_offset; 
    // Limpio la página
    zero_page(page_base_address);
    // elimino la page table entry vinculada
    page_table_entry.attrs = 0;
    page_table_entry.page = 0;
    // Actualizo la tlb
    tlbflush();
    return phy_page_start;

}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
    
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  // En caso de que si, mapear la pagina
}
